function RSK = RSKreadprofiles(RSK, profileNum, direction, latency)

% RSKreadprofiles - Read individual profiles (e.g. upcast and
%                   downcast) from an rsk file.
%
% Syntax:  RSK = RSKreadprofiles(RSK, profileNum, direction)
% 
% Reads profiles, including up and down casts, from the events
% contained in an rsk file. The profiles are written as fields in a
% structure array, divided into upcast and downcast fields, which can
% be indexed individually.
%
% The profile events are parsed from the events table using the
% following types (see RSKconstants.m):
%   33 - Begin upcast
%   34 - Begin downcast
%   35 - End of profile cast
%
% Currently the function assumes that upcasts and downcasts come in
% pairs, as would be recorded by a continuously recording
% logger. Future versions may be better at parsing more complicated
% deployments, such as thresholds or scheduled profiles.
% 
% Inputs: 
%    RSK - Structure containing the logger data read
%                     from the RSK file.
%
%    profileNum - vector identifying the profile numbers to read. This
%          can be used to read only a subset of all the profiles.
%
%    direction - `up` for upcast, `down` for downcast, or `both` for
%          all. Default is `down`.
%
%    latency - the latency, or time lag, in seconds, caused by the slowest
%          responding sensor. When reading profiles the event times must be
%          shifted by this value to line up with the data time stamps.
%
% Outputs:
%    RSK - RSK structure containing individual profiles
%
% Examples:
%
%    rsk = RSKopen('profiles.rsk');
%
%    % read all profiles
%    rsk = RSKreadprofiles(rsk);
%
%    % read selective upcasts
%    rsk = RSKreadprofiles(rsk, [1 3 10], 'up');
%
%
%    % read all casts for a logger with 5 second latency
%    rsk = RSKreadprofiles(rsk, [], [], 5);
%
% See also: RSKreaddata, RSKreadevents, RSKplotprofiles
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-06-29

if ~isfield(RSK, 'profiles') 
    error('No profiles events in this RSK');
end
nprof = min([length(RSK.profiles.downcast.tstart) length(RSK.profiles.upcast.tstart)]);        

if nargin == 1
    nprof = min([length(RSK.profiles.downcast.tstart) length(RSK.profiles.upcast.tstart)]);
    profileNum = 1:nprof; % default read all profiles
    direction = 'down'; % default read downcasts
    latency = 0;
elseif nargin == 2
    direction = 'down';
    latency = 0;
elseif nargin == 3
    latency = 0;
end
if isempty(profileNum) profileNum = 1:nprof; end
if isempty(direction) direction = 'down'; end
if isempty(latency) latency = 0; end

nup = length(profileNum);
ndown = length(profileNum);

if strcmp(direction, 'down') | strcmp(direction, 'both')
    RSK.profiles.downcast.data(ndown).tstamp = [];
    RSK.profiles.downcast.data(ndown).values = [];
    % loop through downcasts
    ii = 1;
    for i=profileNum
        tstart = RSK.profiles.downcast.tstart(i)-latency/86400;
        tend = RSK.profiles.downcast.tend(i)-latency/86400;
        tmp = RSKreaddata(RSK, tstart, tend);
        RSK.profiles.downcast.data(ii).tstamp = tmp.data.tstamp;
        RSK.profiles.downcast.data(ii).values = tmp.data.values;
        % upddate instrumentsChannels fields
        RSK.instrumentChannels = tmp.instrumentChannels;
        ii = ii + 1;
    end
    RSK.channels = tmp.channels;
end

if strcmp(direction, 'up') | strcmp(direction, 'both')
    RSK.profiles.upcast.data(nup).tstamp = [];
    RSK.profiles.upcast.data(nup).values = [];
    Schannel = find(strncmp('Salinity', {RSK.channels.longName}, 4));
    RSK.channels(Schannel) = [];
    % loop through upcasts
    ii = 1;
    for i=profileNum
        tstart = RSK.profiles.upcast.tstart(i)-latency/86400;
        tend = RSK.profiles.upcast.tend(i)-latency/86400;
        tmp = RSKreaddata(RSK, tstart, tend);
        RSK.profiles.upcast.data(ii).tstamp = tmp.data.tstamp;
        RSK.profiles.upcast.data(ii).values = tmp.data.values;
        % upddate instrumentsChannels fields
        RSK.instrumentChannels = tmp.instrumentChannels;
        ii = ii + 1;
    end
    RSK.channels = tmp.channels;
end
