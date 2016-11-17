function RSKplotdata(RSK)

% RSKplotdata - Plot summaries of logger data
%
% Syntax:  RSKplotdata(RSK)
% 
% This generates a plot, similar to the thumbnail plot, only using the
% full 'data' that you read in, rather than just the thumbnail view.
% It tries to be intelligent about the subplots and channel names, so
% you can get an idea of how to do better processing.
% 
% Inputs:
%    RSK - Structure containing the logger metadata and data
%
% Example: 
%    RSK=RSKopen('sample.rsk');  
%    RSK=RSKreaddata(RSK);  
%    RSKplotdata(RSK);  
%
% See also: RSKplotthumbnail, RSKplotburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com

% FIXMEs:
% * plot data - needs time axis sorting
% * doesn't display the date if all data within one day :(

if isfield(RSK,'data')==0
    disp('You must read a section of data in first!');
    disp('Use RSKreaddata...')
    return
end
numchannels = size(RSK.data.values,2);

for n=1:numchannels
    subplot(numchannels,1,n)
    plot(RSK.data.tstamp,RSK.data.values(:,n),'-')
    title(RSK.channels(n).longName);
    ylabel(RSK.channels(n).units);
    ax(n)=gca;
    datetick('x')  % doesn't display the date if all data within one day :(
    
end
linkaxes(ax,'x')
shg
