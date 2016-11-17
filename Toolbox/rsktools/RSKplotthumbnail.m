function RSKplotthumbnail(RSK)

% RSKplotthumbnail - Plot summaries of logger data thumbnails
%
% Syntax:  RSKplotthumbnail(RSK)
% 
% This generates a summary plot of the thumbnail data in the RSK
% structure. This is usually a plot of about 4000 points.  Each time
% value has a max and a min data value so that all spikes are visible
% even though the dataset is down-sampled. It tries to be intelligent
% about the subplots and channel names, so you can get an idea of how
% to do better processing.
% 
% Inputs:
%    RSK - Structure containing the logger metadata and thumbnails
%
% Example: 
%    RSK=RSKopen('sample.rsk');  
%    RSKplotthumbmail(RSK);  
%
% See also: RSKopen, RSKplotdata, RSKplotburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com

% FIXMEs:
% * plot data - needs time axis sorting
% * doesn't display the date if all data within one day :(

numchannels = size(RSK.thumbnailData.values,2);

for n=1:numchannels
    subplot(numchannels,1,n)
    plot(RSK.thumbnailData.tstamp,RSK.thumbnailData.values(:,n),'-')
    title(RSK.channels(n).longName)
    datetick('x')
end
shg
