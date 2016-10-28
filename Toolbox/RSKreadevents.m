function RSK = RSKreadevents(RSK,t1,t2)

% modified 20/March/2013 
% -- improve handling when no data is found in interval
% -- permit only one argument, then ALL data is read (caveat emptor)

if nargin==1 % user wants to read ALL the events
    t1 = datenum2RSKtime(RSK.epochs.startTime);
    t2 = datenum2RSKtime(RSK.epochs.endTime);
else
    t1 = datenum2RSKtime(t1);
    t2 = datenum2RSKtime(t2);
end
sql = ['select tstamp/1.0 as tstamp,* from events where tstamp/1.0 between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = mksqlite(sql);
if isempty(results)
    disp('No data found in that interval')
    return
end
results = rmfield(results,'tstamp_1'); % get rid of the corrupted one

results = RSKarrangedata(results);

t=results.tstamp';
results.tstamp = RSKtime2datenum(t); % convert RSK millis time to datenum

RSK.events=results;

