function utime = datenum2unixtime(dnum)


utime = double(floor(86400 * (dnum -datenum('01-Jan-1970'))));

