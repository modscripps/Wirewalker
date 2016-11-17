function [RSK, dbid] = RSKopen(fname)

% RSKopen - Opens an RBR RSK file and reads metadata and thumbnails.
%
% Syntax:  [RSK, dbid] = RSKopen(fname)
% 
% RSKopen makes a connection to an RSK (sqlite format) database as
% obtained from an RBR logger and reads in the instrument metadata as
% well as a thumbnail of the stored data. RSKopen assumes only a
% single instrument deployment is contained in the RSK file. The
% thumbnail usually contains about 4000 points, and thus avoids
% reading large amounts of data that can be contained in the
% database. Each time value has a maximum and a minimum data value so
% that all spikes are visible even though the dataset is down-sampled.
%
% RSKopen requires a working mksqlite library. We have included a
% couple of versions here for Windows (32/64 bit), Linux (64 bit) and
% Mac (64 bit), but you might need to compile another version.  The
% mksqlite-src directory contains everything you need and some
% instructions from the original author.  You can also find the source
% through Google.
%
% Note: If the file was recorded from an |rt instrument there is no thumbnail data.
%
% Inputs:
%    fname - filename of the RSK file
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnails
%    dbid - database id returned from mksqlite
%
% Example: 
%    RSK=RSKopen('sample.rsk');  
%
% See also: RSKplotthumbnail, RSKreaddata, RSKreadevents, RSKreadburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-11-03

RSKconstants

if nargin==0
    fname=uigetfile({'*.rsk','*.RSK'},'Choose an RSK file');
end
if ~exist(fname,'file')
    disp('File cannot be found')
    RSK=[];dbid=[];
    return
end
dbid = mksqlite('open',fname);

RSK.dbInfo = mksqlite('select version,type from dbInfo');
vsnString = RSK.dbInfo.version;
vsn = strread(vsnString,'%s','delimiter','.');
vsnMajor = str2num(vsn{1});
vsnMinor = str2num(vsn{2});
vsnPatch = str2num(vsn{3});
if vsnMajor > latestRSKversionMajor
    warning(['RSK version ' vsnString ' is newer than your RSKtools version. It is recommended to update RSKtools at https://rbr-global.com/support/matlab-tools']);
elseif (vsnMajor == latestRSKversionMajor) & (vsnMinor > latestRSKversionMinor)
    warning(['RSK version ' vsnString ' is newer than your RSKtools version. It is recommended to update RSKtools at https://rbr-global.com/support/matlab-tools']);
elseif (vsnMajor == latestRSKversionMajor) & (vsnMinor == latestRSKversionMinor) & (vsnPatch > latestRSKversionPatch)
    warning(['RSK version ' vsnString ' is newer than your RSKtools version. It is recommended to update RSKtools at https://rbr-global.com/support/matlab-tools']);
end

RSK.datasets = mksqlite('select * from datasets');
RSK.datasetDeployments = mksqlite('select * from datasetDeployments');

% As of RSK v1.13.4 coefficients is it's own table. We add it back into calibration to be consistent with previous versions.
if (vsnMajor >= 1) & (vsnMinor >= 13) & (vsnPatch >= 4)
    RSK.parameters = mksqlite('select * from parameters');
    RSK.parameterKeys = mksqlite('select * from parameterKeys'); 
    try
        RSK.calibrations = mksqlite('select * from calibrations');
        RSK.coefficients = mksqlite('select * from coefficients');
        RSK = coef2cal(RSK);
    catch
    end
else
    try 
        RSK.calibrations = mksqlite('select * from calibrations');
    catch % ignore if there is an error, rsk files from an easyparse logger  do not contain calibrations
    end
end
        
RSK.instruments = mksqlite('select * from instruments');
try
    RSK.instrumentChannels = mksqlite('select * from instrumentChannels');
catch
end
try
    RSK.ranging = mksqlite('select * from ranging');
catch
end
try
    RSK.instrumentSensors = mksqlite('select * from instrumentSensors');
catch % ignore if there is an error, rsk files from an easyparse logger do not contain instrument sensors table
end

RSK.channels = mksqlite('select longName,units from channels');
% remove derived channel names (because the data aren't there anyway)
% but only do this if it's NOT an EP format rsk
if ~strcmp(RSK.dbInfo(end).type, 'EPdesktop')
    isDerived = mksqlite('select isDerived from channels');
    isMeasured = ~[isDerived.isDerived];
    for c = length(isMeasured):-1:1
        if ~isMeasured(c) RSK.channels(c) = []; end
        if ~isMeasured(c) RSK.instrumentChannels(c) = []; end
    end
end

RSK.epochs = mksqlite('select deploymentID,startTime/1.0 as startTime, endTime/1.0 as endTime from epochs');
RSK.epochs.startTime = RSKtime2datenum(RSK.epochs.startTime);
RSK.epochs.endTime = RSKtime2datenum(RSK.epochs.endTime);

RSK.schedules = mksqlite('select * from schedules');


try
    RSK.appSettings = mksqlite('select * from appSettings');
catch
end
RSK.deployments = mksqlite('select * from deployments');

%Realtime instruments do not have thumbnailData.
try 
    RSK.thumbnailData = RSKreadthumbnail;
catch
end




%% Want to read in events so that we can get the profile event metadata
% 
% FIXME: what happens when there are no profile events? Should just skip this
tmp = RSKreadevents(RSK);
try
    events = tmp.events;
catch
end

if exist('events', 'var')
    nup = length(find(events.values(:,2) == eventBeginUpcast));
    ndown = length(find(events.values(:,2) == eventBeginDowncast));
    
    if ~(nup == 0 & ndown == 0)
        
        iup = find(events.values(:,2) == eventBeginUpcast);
        idown = find(events.values(:,2) == eventBeginDowncast);
        iend = find(events.values(:,2) == eventEndcast);
        
        % which is first?
        if (idown(1) < iup(1)) 
            idownend = iend(1:2:end);
            iupend = iend(2:2:end);
        else
            idownend = iend(2:2:end);
            iupend = iend(1:2:end);
        end
        
        RSK.profiles.downcast.tstart = events.tstamp(idown);
        RSK.profiles.downcast.tend = events.tstamp(idownend);
        RSK.profiles.upcast.tstart = events.tstamp(iup);
        RSK.profiles.upcast.tend = events.tstamp(iupend);
        
    end
end
