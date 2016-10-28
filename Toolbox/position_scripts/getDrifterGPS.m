function getDrifterGPS(timewindow,timenow,varargin)
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
load('BuoyData/Drifter_GPS_Instruments.mat');

Drifter_GPS = repmat(struct('DeviceID',[],'DateTime',[],'Latitude',[],'Longitude',[]),size(Drifter_GPS_Instruments.DeviceID));

for i = 1:numel(Drifter_GPS_Instruments.DeviceID)
    ind = str2double(Drifter_GPS_Instruments.DeviceID{i})==ASSETS.id & strcmpi(Drifter_GPS_Instruments.DeviceType{i},ASSETS.type);
    
    Drifter_GPS(i).DeviceID = repmat(Drifter_GPS_Instruments.DeviceID{i},size(ASSETS.id(ind)));
    Drifter_GPS(i).DateTime = ASSETS.dtnum(ind);
    Drifter_GPS(i).Latitude = ASSETS.lat(ind);
    Drifter_GPS(i).Longitude = ASSETS.lon(ind);
    
    ind = Drifter_GPS(i).DateTime<=timenow & Drifter_GPS(i).DateTime>=datepre...
        & (min(Drifter_GPS(i).Latitude)>13 & max(Drifter_GPS(i).Latitude)>13);
    Drifter_GPS(i).DeviceID = Drifter_GPS(i).DeviceID(ind);
    Drifter_GPS(i).DateTime = Drifter_GPS(i).DateTime(ind);
    Drifter_GPS(i).Latitude = Drifter_GPS(i).Latitude(ind);
    Drifter_GPS(i).Longitude = Drifter_GPS(i).Longitude(ind);
end

save('BuoyData/Drifter_GPS.mat','Drifter_GPS');

end