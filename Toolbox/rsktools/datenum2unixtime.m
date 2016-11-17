function utime = datenum2unixtime(dnum)

% datenum2unixtime - Convert MATLAB datenum format to unix time
%                    (i.e. the number of seconds since 1970-01-01)
%
% Syntax:  utime = datenum2unixtime(dnum)
% 
% Converts MATLAB datenum format to "unix time", (i.e. POSIX time,
% the number of seconds since 1970-01-01 00:00:00.000).
%
% Inputs:
%    dnum - MATLAB datenum
% 
% Outputs:
%    utime - Unix time. The number of seconds since 1970-01-01.
%
% Example: 
%    datenum2unixtime(datenum('01-Jan-2015'))
%
%    ans =
%
%         1.420070400000000e+09
%
% See also: unixtime2datenum, RSKtime2datenum, datenum2RSKtime
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com

utime = double(floor(86400 * (dnum - datenum('01-Jan-1970'))));

