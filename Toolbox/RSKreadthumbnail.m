function results = RSKreadthumbnail
sql = ['select tstamp/1.0 as tstamp,* from thumbnailData order by tstamp'];
results = mksqlite(sql);
results = rmfield(results,'tstamp_1'); % get rid of the corrupted one

results = RSKarrangedata(results);

results.tstamp = RSKtime2datenum(results.tstamp'); % convert unix time to datenum

