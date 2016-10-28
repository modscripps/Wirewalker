function [RSK,dbid] = RSKopen(fname)
% assumes only a single instrument deployment in RSK
%
% modified 11/August/2014 avoid raising an error when reading calibration
% and instrument sensors table from an rsk file.
% modified 3/February/2014
%   added uigetfile call if filename not specified on command line
% modified 21/March/2013
%   added error message if file does not exist

if nargin==0
    fname=uigetfile({'*.rsk','*.RSK'},'Choose an RSK file');
end

if ~exist(fname,'file')
    disp('File cannot be found')
    RSK=[];dbid=[];
    return
end
dbid = mksqlite('open',fname);

RSK.dbInfo = mksqlite('select version from dbInfo');

try
RSK.calibrations = mksqlite('select * from calibrations');
catch % ignore if there is an error, rsk files from an easyparse logger  do not contain calibrations
end

RSK.datasets = mksqlite('select * from datasets');
RSK.datasetDeployments = mksqlite('select * from datasetDeployments');

RSK.instruments = mksqlite('select * from instruments');
RSK.instrumentChannels = mksqlite('select * from instrumentChannels');

try
RSK.instrumentSensors = mksqlite('select * from instrumentSensors');
catch % ignore if there is an error, rsk files from an easyparse logger do not contain instrument sensors table
end

RSK.channels = mksqlite('select longName,units from channels');

RSK.epochs = mksqlite('select deploymentID,startTime/1.0 as startTime, endTime/1.0 as endTime from epochs');
RSK.epochs.startTime = RSKtime2datenum(RSK.epochs.startTime);
RSK.epochs.endTime = RSKtime2datenum(RSK.epochs.endTime);

RSK.schedules = mksqlite('select * from schedules');


RSK.appSettings = mksqlite('select * from appSettings');
RSK.deployments = mksqlite('select * from deployments');

RSK.thumbnailData = RSKreadthumbnail;
