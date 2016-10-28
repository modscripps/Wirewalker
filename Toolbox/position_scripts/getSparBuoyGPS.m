function getSparBuoyGPS(timewindow,timenow,varargin)
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

% This function should be ran to set up the Drifter Buoy for ASIRI 2015
load('/Volumes/OPG Mini/ASIRI/2015/ScienceShare/solo/assets_positions.mat');
load('/Volumes/scienceparty_share/solo/assets_positions.mat');
load('BuoyData/SparBuoy_GPS_Instruments.mat');

SparBuoy_GPS = repmat(struct('DeviceID',[],'DateTime',[],'Latitude',[],'Longitude',[]),size(SparBuoy_GPS_Instruments.DeviceID));

for i = 1:numel(SparBuoy_GPS_Instruments.DeviceID)
    ind = str2double(SparBuoy_GPS_Instruments.DeviceID{i})==ASSETS.id & strcmpi(SparBuoy_GPS_Instruments.DeviceType{i},ASSETS.type);
    
    SparBuoy_GPS(i).DeviceID = repmat(SparBuoy_GPS_Instruments.DeviceID{i},size(ASSETS.id(ind)));
    SparBuoy_GPS(i).DateTime = ASSETS.dtnum(ind);
    SparBuoy_GPS(i).Latitude = ASSETS.lat(ind);
    SparBuoy_GPS(i).Longitude = ASSETS.lon(ind);
    
    ind = SparBuoy_GPS(i).DateTime<=timenow & SparBuoy_GPS(i).DateTime>=datepre...
        & (min(SparBuoy_GPS(i).Latitude)>13 & max(SparBuoy_GPS(i).Latitude)>13);
    SparBuoy_GPS(i).DeviceID = SparBuoy_GPS(i).DeviceID(ind);
    SparBuoy_GPS(i).DateTime = SparBuoy_GPS(i).DateTime(ind);
    SparBuoy_GPS(i).Latitude = SparBuoy_GPS(i).Latitude(ind);
    SparBuoy_GPS(i).Longitude = SparBuoy_GPS(i).Longitude(ind);
end

save('BuoyData/SparBuoy_GPS.mat','SparBuoy_GPS');

end