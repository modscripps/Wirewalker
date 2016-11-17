function RSK = RSKreadburstdata(RSK, t1, t2)

% RSKreadburstdata - Reads the burst data tables from an RBR RSK
%                    SQLite file. Use with RSKreadevents to
%                    separate bursts.
%
% Syntax:  RSK = RSKreadburstdata(RSK, t1, t2)
% 
% Reads the burst data tables from the RSK file previously opened with
% RSKopen(). Will either read the entire burst data structre, or a
% specified subset. Use in conjunction with RSKreadevents to
% separate bursts.
% 
% Inputs: 
%    RSK - Structure containing the logger metadata and thumbnails
%          returned by RSKopen. If provided as the only argument the
%          burst data for the entire file is read. Depending on the
%          amount of data in your dataset, and the amount of memory in
%          your computer, you can read bigger or smaller chunks before
%          Matlab will complain and run out of memory.
%     t1 - Optional start time for range of data to be read,
%          specified using the MATLAB datenum format.
%     t2 - Optional end time for range of data to be read,
%          specified using the MATLAB datenum format.
%
% Outputs:
%    RSK - Structure containing the logger metadata, along with the
%          added {FIXME:'burstdata'} fields. Note that this replaces
%          any previous data that was read this way.
%
% Example: 
%    RSK = RSKopen('sample.rsk');  
%    RSK = RSKreadburstdata(RSK);
%
% See also: RSKopen, RSKreaddata, RSKreadevents
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-03-02

if nargin==1 % user wants to read ALL the data
    t1 = datenum2RSKtime(RSK.epochs.startTime);
    t2 = datenum2RSKtime(RSK.epochs.endTime);
else
    t1 = datenum2RSKtime(t1);
    t2 = datenum2RSKtime(t2);
end
sql = ['select tstamp/1.0 as tstamp,* from burstdata where tstamp/1.0 between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = mksqlite(sql);
if isempty(results)
    disp('No data found in that interval')
    return
end
results = rmfield(results,'tstamp_1'); % get rid of the corrupted one

%% RSK version >= 1.12.2 now has a datasetID column in the data table
% Look for the presence of that column and extract it from results
if sum(strcmp('datasetID', fieldnames(results))) > 0
    datasetID = [results(:).datasetID]';
    results = rmfield(results, 'datasetID'); % get rid of the datasetID column
    hasdatasetID = 1;
else 
    hasdatasetID = 0;
end

results = RSKarrangedata(results);

t=results.tstamp';
results.tstamp = RSKtime2datenum(t); % convert RSK millis time to datenum

if hasdatasetID
    results.datasetID = datasetID;
end
RSK.burstdata=results;

