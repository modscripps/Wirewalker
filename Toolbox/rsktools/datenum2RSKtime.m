function rtime = datenum2RSKtime(dnum)

% datenum2RSKtime - Convert MATLAB datenum format to RSK logger time
%
% Syntax:  rtime = datenum2RSKtime(dnum)
% 
% Converts MATLAB datenum format to 'rtime', as recorded by the logger.
%
% Inputs:
%    dnum - MATLAB datenum
% 
% Outputs:
%    rtime - Raw time read from the RSK file, corresponding to
%    milliseconds elapsed since January 1 1970 (i.e. unix time or
%    POSIX time). 
%
% Example: 
%    datenum2RSKtime(datenum('01-Jan-2015'))
%
%    ans =
%
%         1.420070400000000e+12
%
% See also: RSKtime2datenum, unixtime2datenum, datenum2unixtime
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com

rtime=datenum2unixtime(dnum)*1000;
