function RSKplotburstdata(RSK)

% RSKplotburstdata - Plot summaries of logger burst data
%
% Syntax:  RSKplotburstdata(RSK)
% 
% This generates a plot, similar to the thumbnail plot, only using the
% full 'burst data' that you read in, rather than just the thumbnail
% view.  It tries to be intelligent about the subplots and channel
% names, so you can get an idea of how to do better processing.
% 
% Inputs:
%    RSK - Structure containing the logger metadata and burst data
%
% Example: 
%    RSK=RSKopen('sample.rsk');  
%    RSK=RSKreadburstdata(RSK);  
%    RSKplotdata(RSK);  
%
% See also: RSKplotthumbnail, RSKplotdata, RSKreadburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com

% FIXMEs:
% * plot data - needs time axis sorting
% * doesn't display the date if all data within one day :(

if isfield(RSK,'burstdata')==0
    disp('You must read a section of burst data in first!');
    disp('Use RSKreadburstdata...')
    return
end
numchannels = size(RSK.burstdata.values,2);

for n=1:numchannels
    subplot(numchannels,1,n)
    plot(RSK.burstdata.tstamp,RSK.burstdata.values(:,n),'-')
    title(RSK.channels(n).longName);
    ylabel(RSK.channels(n).units);
    ax(n)=gca;
    datetick('x')  % doesn't display the date if all data within one day :(
    
end
linkaxes(ax,'x')
shg
