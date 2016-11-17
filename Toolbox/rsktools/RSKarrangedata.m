function data = RSKarrangedata(results_struct)

% RSKarrangedata - Internal RSKtools function to clean data
%                  structures during reading.
%
% Syntax:  data = RSKarrangedata(results_struct)
% 
% An internal RSKtools function for arranging data read from an RSK
% SQLite database, and cleaning setting zeros for empty values
% (usually occurs at the beginning of profiling runs when some sensors
% are still settling).
% 
% Inputs: 
%    results_struct - Structure containing the logger data read
%                     from the RSK file.
%
% Outputs:
%    data - Structure containing the arranged logger data, ordered
%           by tstamp.
%
% See also: RSKreaddata, RSKreadevents, RSKreadburstdata, RSKreadthumbnail
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2013-03-20

s=struct2cell(results_struct);  % make it easier to deal with

data.tstamp = [s{1,:}]'; % tstamp is in the first column

values = s(2:end,:);  % pull out just the values columns

% there can be empty cells in this array, if there were glitching values
% (usually occurs at the beginning of profiling runs when some sensors are 
% still settling.
% This sets them to zero cleanly.

blanks = cellfun('isempty',values);
values(blanks)={0};

data.values = cell2mat(values)'; % don't forget the transpose :)


