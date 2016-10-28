function getSoloGPS(timewindow,timenow,varargin)
DeployTime=varargin;

if ~exist('timewindow','var')
    timewindow = 1/2; % unit: day
end
if ~exist('timenow','var')
    timenow = now;
end
if isempty(DeployTime)
    datepre = timenow-timewindow;
else
    datepre=DeployTime{1};
end

% this is to read the position of Solo Floats updated by Emily
dataDir = '/Volumes/OPG Mini/ASIRI/2015/ScienceShare/solo/';
% dataDir = '/Volumes/scienceparty_share/solo/';
mySoloFiles = dir([dataDir 'S*.txt']);

SoloFloats_GPS = repmat(struct('DeviceID',[],'DateTime',[],'Latitude',[],'Longitude',[]),size(mySoloFiles));

for i = 1:numel(mySoloFiles)
    fname = ([dataDir mySoloFiles(i).name]);
    fid = fopen(fname,'r');
    data = textscan(fid,'%s %s %s %s %f %f','delimiter','-,');
    frewind(fid);
    s = fread(fid,'*char')';
    
    fclose(fid);
    SoloFloats_GPS(i).DeviceID = data{1};
    SoloFloats_GPS(i).DateTime = NaN(size(SoloFloats_GPS(i).DeviceID));
    date_S = data{3};
    time_S = data{4};
    for j = 1:numel(SoloFloats_GPS(i).DeviceID)
        SoloFloats_GPS(i).DateTime(j) = datenum([date_S{j} ' ' time_S{j}]);
    end
    SoloFloats_GPS(i).Latitude = data{5};
    SoloFloats_GPS(i).Longitude = data{6};
    
    ind = SoloFloats_GPS(i).DateTime<=timenow & SoloFloats_GPS(i).DateTime>=datepre;
    SoloFloats_GPS(i).DeviceID = SoloFloats_GPS(i).DeviceID(ind);
    SoloFloats_GPS(i).DateTime = SoloFloats_GPS(i).DateTime(ind);
    SoloFloats_GPS(i).Latitude = SoloFloats_GPS(i).Latitude(ind);
    SoloFloats_GPS(i).Longitude = SoloFloats_GPS(i).Longitude(ind);
end

save('BuoyData/SoloFloats_GPS.mat','SoloFloats_GPS');

end