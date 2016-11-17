function RSKplotprofiles(RSK, profileNum, field, direction)

% RSKplotprofiles - plots profiles from an RSK object, based on upcast
%                   and downcast events
%
% Syntax:  RSKplotprofiles(RSK, profileNum, field, direction)
% 
% Plots profiles from automatically detected casts. If called with one
% argument, will default to plotting downcasts of temperature for all
% profiles in the structure.
%
% Inputs: 
%    RSK - Structure containing the logger data read
%          from the RSK file.
% 
%    profileNum - optional profile number to plot. Default plots all
%          detected profiles
%
%    field - named field to plot (e.g. temperature, salinity, etc)
%
%    direction - `up` for upcast, `down` for downcast, or `both` for
%          all. Default is `both
%
% Examples:
%
%    rsk = RSKopen('profiles.rsk');
%
%    % read all profiles
%    rsk = RSKreadprofiles(rsk);
%
%    % plot all profiles
%    RSKplotprofiles(rsk);
%
%    % plot selective downcasts
%    RSKplotprofiles(rsk, [1 5 10]);
%
%    % plot conductivity for selective downcasts
%    RSKplotprofiles(rsk, [1 5 10], 'conductivity');
%
% See also: RSKreadprofiles, RSKreaddata, RSKreadevents
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2015-10-06

if nargin == 1
    if ~isfield(RSK.profiles.downcast, 'data') error('No downcasts in RSK'); end
    profileNum = 1:length(RSK.profiles.downcast.data);
    field = 'temperature';
    direction = 'down';
elseif nargin == 2
    field = 'temperature';
    direction = 'down';
elseif nargin == 3
    direction = 'down';
end
if isempty(direction) direction = 'down'; end
if isempty(field) field = 'temperature'; end
if isempty(profileNum) 
    if strcmp(direction, 'down')
        if ~isfield(RSK.profiles.downcast, 'data')
            error('No downcasts in RSK');
        else 
            profileNum = 1:length(RSK.profiles.downcast.data); 
        end
    elseif strcmp(direction, 'up')
        if ~isfield(RSK.profiles.upcast, 'data')
            error('No upcasts in RSK');
        else 
            profileNum = 1:length(RSK.profiles.upcast.data); 
        end
    elseif strcmp(direction, 'both')
        if ~isfield(RSK.profiles.downcast, 'data')
            error('No downcasts in RSK');
        end
        if ~isfield(RSK.profiles.upcast, 'data')
            error('No upcasts in RSK');
        end
        profileNum = 1:min([length(RSK.profiles.upcast.data) length(RSK.profiles.downcast.data)]); 
    end
end
if strcmp(direction, 'down')
    if ~isfield(RSK.profiles.downcast, 'data')
        error('No downcasts in RSK');
    end
elseif strcmp(direction, 'up')
    if ~isfield(RSK.profiles.upcast, 'data')
        error('No upcasts in RSK');
    end
elseif strcmp(direction, 'both')
    if ~isfield(RSK.profiles.downcast, 'data')
        error('No downcasts in RSK');
    end
    if ~isfield(RSK.profiles.upcast, 'data')
        error('No upcasts in RSK');
    end
end    

% find column number of field
pcol = find(strncmp('pressure', lower({RSK.channels.longName}), 4));
pcol = pcol(1); 
col = find(strncmp(field, lower({RSK.channels.longName}), 4));
% Is it a "hidden" channel?
if ~strncmp(RSK.dbInfo(end).type, 'EP', 2)
    isHidden = [];
    for i=1:length(col)
        isHidden = [isHidden RSK.instrumentChannels(col(i)).channelStatus ~= 0];
    end
    % only plot non-hidden channels
    col = col(~isHidden);
end

% clf
ax = gca; ax.ColorOrderIndex = 1;
pmax = 0;
if strcmp(direction, 'up') | strcmp(direction, 'both')
    for i=profileNum
        p = RSK.profiles.upcast.data(i).values(:, pcol) - 10.1325; % FIXME: should read ptAm from rskfile
        plot(RSK.profiles.upcast.data(i).values(:, col), p)
        hold on
        pmax = max([pmax; p]);
    end
end
if strcmp(direction, 'both') ax = gca; ax.ColorOrderIndex = 1; end
if strcmp(direction, 'down') | strcmp(direction, 'both')
    for i=profileNum
        p = RSK.profiles.downcast.data(i).values(:, pcol) - 10.1325; % FIXME: should read pAtm from rskfile
        plot(RSK.profiles.downcast.data(i).values(:, col), p)
        hold on
        pmax = max([pmax; p]);
    end
end
grid

xlab = [RSK.channels(col).longName ' [' RSK.channels(col).units, ']'];
ylim([0 pmax])
set(gca, 'ydir', 'reverse')
ylabel('Sea pressure [dbar]')
xlabel(xlab)
if strcmp(direction, 'down')
    title('Downcasts')
elseif strcmp(direction, 'up')
    title('Upcasts')
elseif strcmp(direction, 'both')
    title('Downcasts and Upcasts')
end
hold off
