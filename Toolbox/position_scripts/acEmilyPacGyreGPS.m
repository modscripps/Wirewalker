function PacGyreGPS = acEmilyPacGyreGPS(IMEI,varargin)
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

if ~exist('IMEI','var')
    IMEI = '';
end

if ~ischar(IMEI)
    error('MATLAB:acPacGyreGPS','Error on your IMEI');
end

IMEI = strtrim(IMEI);

argsNameToCheck = {'startDate','endDate','CommID', 'deviceName', 'DataDateTime',...
    'GPSLatitude', 'GPSLongitude', 'Submerged', 'gpsQuality', 'BatteryVoltage', ...
    'SST', 'IridiumLatitude', 'IridiumLongitude', 'IridiumRadiusKm','orgName',...
    'bPressTend', 'windDir', 'windSpeed', 'bPress', 'SurfaceSalinity', 'temperature7m',...
    'salinity7m', 'temperature15m', 'salinity15m'};
argsVars = {'CommID', 'deviceName', 'DataDateTime',...
    'GPSLatitude', 'GPSLongitude', 'Submerged', 'gpsQuality', 'BatteryVoltage', ...
    'SST', 'IridiumLatitude', 'IridiumLongitude', 'IridiumRadiusKm','orgName',...
    'bPressTend', 'windDir', 'windSpeed', 'bPress', 'SurfaceSalinity', 'temperature7m',...
    'salinity7m', 'temperature15m', 'salinity15m'};

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
        error('MATLAB:acPacGyreGPS',['Check your input arguments again (' upper(varargin{index}) ')']);
    end
    
    
    if i < 3 % checking for StartDate and EndDate
        if index == (nargin-1)
            error('MATLAB:acPacGyreGPS','Missing input arguments');
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

myGPS = acquireGPS(IMEI,startDate,endDate);
PacGyreGPS = [];
indices = find(argsOutVars);

if isempty(myGPS)
    for i = 1:length(indices)
        if indices(i)== 1
            PacGyreGPS.(argsVars{indices(i)}) = cellstr(IMEI);
        else
            PacGyreGPS.(argsVars{indices(i)}) = [];
        end
    end
    return;
end

for i = 1:length(indices)
    PacGyreGPS.(argsVars{indices(i)}) = myGPS{indices(i)};
end

end

% this function requires internet connection to get data from the Pacific
% Gyre website
function GPS = acquireGPS(imei,StartDate,EndDate)
try
    s = urlread('http://api.pacificgyre.com/pgapi/getData.aspx','get',...
        {'userName','asiri_PG13',...
        'password','Goonies',...
        'deviceNames','',...
        'commIDs',imei,...
        'startDate',StartDate,...
        'endDate',EndDate,...
        'commentCharacters','$',... % comment character for debug lines
        'delimiter','\t',...
        'eol',char(10),... %end of line character
        'debug','false',... %returns the information passed to server
        'headers','false',... %label line for columns
        'fixedWidth','undefined',...
        'format','',... % certain formats include Raw(''), CSV,XLS,KML
        'download','Yes',...
        'filename','pacgyre'});
catch err
    error(err.identifier,err.message);
    disp('PLEASE MAKE SURE THAT MATLAB CAN CONNECT TO THE INTERNET!');
end
if isempty(s)
    GPS = [];
    return;
end
GPS = textscan(s,'%s        %s          %s              %f          %f              %s          %f          %f              %f  %f              %f                  %f              %s      %f          %f      %f          %f      %f              %f              %f          %f              %f         ','delimiter','\t','commentstyle','$');
%                 CommID	deviceName	DataDateTime	GPSLatitude GPSLongitude    Submerged   gpsQuality	BatteryVoltage	SST	IridiumLatitude	IridiumLongitude	IridiumRadiusKm	orgName	bPressTend	windDir	windSpeed	bPress	SurfaceSalinity	temperature7m	salinity7m	temperature15m	salinity15m
GPS{3} = datenum(GPS{3});
end

% function gps_iop=acquireIOP;
%     s=urlread('http://iop.apl.washington.edu/ice/txt/300034013757350_GP01.txt');
%     c=textscan(s,'%s','delimiter',' ');
%     c=c{1};
%     cc=c(4:4:end);
% 
%    clear gps_iop; k=1;
%     for i=1:length(cc)
%         com=strfind(cc{i},',');
%         if strcmp(cc{i}(com(6)+1:com(7)-1),'256')==1
%             disp('bad')
%             continue
%         end
%         gps_iop.time(k)=str2double(cc{i}(com(4)+1:com(5)-1))+datenum([2000 01 01 00 00 00])+str2double(cc{i}(com(5)+1:com(6)-1))/24;
%         gps_iop.lat(k)=str2double(cc{i}(1:com(1)-1))+str2double(cc{i}(com(1)+1:com(2)-1))/60;
%         gps_iop.lon(k)=str2double(cc{i}(com(2)+1:com(3)-1))+str2double(cc{i}(com(3)+1:com(4)-1))/60;
% 
%         k=k+1; 
%     end
% end