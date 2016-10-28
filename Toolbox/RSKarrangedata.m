function data=RSKarrangedata(results_struct)

% modified 20/March/2013 to handle empty cells properly

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


