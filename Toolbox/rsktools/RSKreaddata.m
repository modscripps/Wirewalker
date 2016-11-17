function RSK = RSKreaddata(RSK, t1, t2)

% RSKreaddata - Reads the data tables from an RBR RSK SQLite file.
%
% Syntax:  RSK = RSKreaddata(RSK, t1, t2)
% 
% Reads the actual data tables from the RSK file previously opened
% with RSKopen(). Will either read the entire data structre, or a
% specified subset. 
% 
% Inputs: 
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen. If provided as the only argument the
%          data for the entire file is read. Depending on the amount
%          of data in your dataset, and the amount of memory in your
%          computer, you can read bigger or smaller chunks before
%          Matlab will complain and run out of memory.
%     t1 - Optional start time for range of data to be read,
%          specified using the MATLAB datenum format.
%     t2 - Optional end time for range of data to be read,
%          specified using the MATLAB datenum format.
%
% Outputs:
%    RSK - Structure containing the logger metadata, along with the
%          added 'data' fields. Note that this replaces any
%          previous data that was read this way.
%
% Example: 
%    RSK = RSKopen('sample.rsk');  
%    RSK = RSKreaddata(RSK);
%
% See also: RSKopen, RSKreadevents, RSKreadburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-09-29

if nargin==1 % user wants to read ALL the data
    t1 = datenum2RSKtime(RSK.epochs.startTime);
    t2 = datenum2RSKtime(RSK.epochs.endTime);
else
    t1 = datenum2RSKtime(t1);
    t2 = datenum2RSKtime(t2);
end

% Select data schema
% Determine 'channelXX' column names
% Build SQL statement from column names
sql = ['select tstamp/1.0 as tstamp,* from data where tstamp/1.0 between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = mksqlite(sql);
if isempty(results)
    disp('No data found in that interval')
    return
end
results = rmfield(results,'tstamp_1'); % get rid of the corrupted one

%% RSK version >= 1.12.2 now has a datasetID column in the data table
% Look for the presence of that column and extract it from results
names = fieldnames(results);
fieldmatch = strcmpi(names, 'datasetid');
hasdatasetID = sum(fieldmatch);

if hasdatasetID
    try
        results = rmfield(results, names(fieldmatch == 1)); % get rid of the datasetID column
%        datasetID = [results(:).datasetID]';
    catch
    end
end

%% RSK version >= 1.12.2 also replaces serialID with instrumentID in the instrumentChannels table
% Look for serialID (in older versions) and replace it
if sum(strcmp('serialID', fieldnames(RSK.instrumentChannels))) > 0
    ic = RSK.instrumentChannels;
    [ic.instrumentID] = ic.serialID;
    ic = rmfield(ic, 'serialID');
    RSK.instrumentChannels = ic;
end

results = RSKarrangedata(results);

t=results.tstamp';
results.tstamp = RSKtime2datenum(t); % convert RSK millis time to datenum

% Does the RSK have all 3 of conductivity, temperature, and pressure, but not salinity?
% If so, calculate practical salinity using TEOS-10 (if it exists)
hasTEOS = exist('gsw_SP_from_C') == 2;
nchannels = length(RSK.channels);
if nchannels >= 3
    hasCTP = strcmp(RSK.channels(1).longName, 'Conductivity') & strcmp(RSK.channels(2).longName, 'Temperature') & strcmp(RSK.channels(3).longName, 'Pressure');
else 
    hasCTP = 0;
end
hasS = any(strcmp({RSK.channels.longName}, 'Salinity'));

if hasTEOS & hasCTP & ~hasS
    % does the RSK already have a salinity channel?
    % FIXME: need to check if salinity exists in the data struct also
    if sum(strcmp({RSK.channels.longName}, 'Salinity')) == 0
        RSK.channels(nchannels+1).longName = 'Salinity';
        RSK.channels(nchannels+1).units = 'PSU';
        % update the instrumentChannels info for the new "channel"
        RSK.instrumentChannels(nchannels+1).instrumentID = RSK.instrumentChannels(1).instrumentID;
        RSK.instrumentChannels(nchannels+1).channelID = RSK.instrumentChannels(nchannels).channelID+1;
        RSK.instrumentChannels(nchannels+1).channelOrder = RSK.instrumentChannels(nchannels).channelOrder+1;
        if ~strncmp(RSK.dbInfo.type, 'EP', 2) RSK.instrumentChannels(nchannels+1).channelStatus = 0; end
        results.longName = {RSK.channels.longName};
        results.units = {RSK.channels.units};
    end
    salinity = gsw_SP_from_C(results.values(:, 1), results.values(:, 2), results.values(:, 3) - 10.1325); % FIXME: use proper pAtm
    results.values = [results.values salinity];
end

% if hasdatasetID
%     results.datasetID = datasetID;
% end
RSK.data=results;
