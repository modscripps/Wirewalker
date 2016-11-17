function results = RSKreadthumbnail

% RSKreadthumbnail - Internal function to read thumbnail data from
%                    an opened RSK file.
%
% Syntax:  results = RSKreadthumbnail
% 
% Reads thumbnail data from an opened RSK SQLite file, called from
% within RSKopen.
%
% Inputs:
%    None - Reads from the currently open RSK database file
%
% Outputs:
%    results - Structure containing the logger thumbnail data
%
% See also: RSKopen
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-03-02

sql = ['select tstamp/1.0 as tstamp,* from thumbnailData order by tstamp'];
results = mksqlite(sql);
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

if hasdatasetID
    results.datasetID = datasetID;
end
results.tstamp = RSKtime2datenum(results.tstamp'); % convert unix time to datenum

