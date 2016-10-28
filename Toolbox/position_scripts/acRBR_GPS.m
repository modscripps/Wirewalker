function RBR_GPS = acRBR_GPS(deviceID,varargin)
% ACPACGYREGPS - aquires GPS positions of a Pacific Gyre GPS Tracking unit
%   with a specific IMEI number.
%
% Please make sure that internet accessibilty is available in MATLAB before
% running this function.
%
% GPS = ACPACGYREGPS(IMEI) - returns a structure containing fields of
%   CommID, deviceName, DataDateTime, GPSLatitude, GPSLongitude, Submerged,
%   gpsQuality, BatteryVoltage, SST, IridiumLatitude, IridiumLongitude,
%   IridiumRadiusKm, orgName, bPressTend, windDir, windSpeed, bPress,
%   SurfaceSalinity, temperature7m, salinity7m, temperature15m, salinity15m
%
% If there are only specific fields needed, the user can specify such field
% by invoking:
%       GPS = ACPACGYREGPS(IMEI,'FIELDNAME1','FIELDNAME2',...);
% The field names are of that specified above.
%
% User also should specify a STARTDATE and ENDDATE of the time period of
% which GPS locations was recorded for the tracking unit:
%
% GPS = GPS = ACPACGYREGPS(IMEI,'STARTDATE',GPSSTARTDATE,'ENDDATE',GPSENDDATE)
%
% GPSSTARTDATE and GPSENDDATE must be date strings with the format
% 'yyyy/mm/dd HH:MM'
%
% Written: 2011 12 San Nguyen (snguyen@opg1.ucsd.edu)
% Updated: 2013 09 17 San Nguyen (snguyen@opg1.ucsd.edu)
%

if ~exist('deviceID','var')
    deviceID = '';
end

if ~ischar(deviceID)
    error('MATLAB:acRBR_GPS','Error on your IMEI');
end

deviceID = strtrim(deviceID);

argsNameToCheck = {'startDate','endDate',...
    'DateTime','Conductivity', 'Temperature', 'Pressure',...
    'Dissolved O2', 'Chlorophyll', 'CDOM', 'Turbidity', 'Pressure (sea)', ...
    'Depth', 'Salinity', 'Latitude', 'Longitude',...
    'HDOP', 'Battery (external)', 'Battery (internal)', 'Battery (buoy)'};
argsVars = {'DateTime','Conductivity', 'Temperature', 'Pressure',...
    'Dissolved O2', 'Chlorophyll', 'CDOM', 'Turbidity', 'Pressure (sea)', ...
    'Depth', 'Salinity', 'Latitude', 'Longitude',...
    'HDOP', 'Battery (external)', 'Battery (internal)', 'Battery (buoy)'};

argsOutVars = false(size(argsVars));

startDate = '';
endDate = '';
index = 1;

% checking for input fields
n_items = nargin-1;
while (n_items > 0)
    argsMatch = strcmpi(varargin{index},argsNameToCheck);
    i = find(argsMatch);
    if isempty(i)
        error('MATLAB:acRBR_GPS',['Check your input arguments again (' upper(varargin{index}) ')']);
    end
    
    
    if i < 3 % checking for StartDate and EndDate
        if index == (nargin-1)
            error('MATLAB:acRBR_GPS','Missing input arguments');
        end
        
        if strcmpi(varargin{index},'startDate')
            startDate = varargin{index+1};
        else
            endDate = varargin{index+1};
        end
        index = index + 2;
        n_items = n_items - 2;
    else % checking for output field requests
        argsOutVars(i-2) = true;
        index = index + 1;
        n_items = n_items - 1;
    end
end

% if no output field was requested, then ouput all fields
if sum(argsOutVars) == 0
    argsOutVars(:) = true;
end
myGPS = acquireGPS(deviceID,startDate,endDate);
RBR_GPS = [];
indices = find(argsOutVars);

if isempty(myGPS)
    for i = 1:length(indices)
        RBR_GPS.(argsVars{indices(i)}) = [];
    end
    return;
end

for i = 1:length(indices)
    RBR_GPS.(argsVars{indices(i)}) = myGPS{indices(i)};
end

end

% this function requires internet connection to get data from the Pacific
% Gyre website
function GPS = acquireGPS(deviceID,StartDate,EndDate)
try
    s = urlread(['http://data.rbr-global.com/scripps/download/' deviceID]);

catch err
    error(err.identifier,err.message);
    disp('PLEASE MAKE SURE THAT MATLAB CAN CONNECT TO THE INTERNET!');
end
if isempty(s)
    GPS = [];
    return;
end
GPS = textscan(s,'%f    %f      %f    %f  %f   %f   %f    %f    %f      %f      %f           %f    %f         %f          %f     %f    %f   %f   %f    %f        %f       %f','delimiter',',','commentstyle','$','HeaderLines',1);
%                Year,  Month,	Day,  Hr, Min, Sec, Cond, Temp,	Press,  DisO2,  Chlorophyll, CDOM, Turbidity, Pres (sea), Depth, Salt, Lat, Lon, HDOP, Bat(ext), Bat(in), Bat(buoy)
GPS{1} = datenum(GPS{1},GPS{2},GPS{3},GPS{4},GPS{5},GPS{6});
GPS=GPS([1,7:end]);
end