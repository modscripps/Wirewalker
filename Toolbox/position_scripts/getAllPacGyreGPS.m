function getAllPacGyreGPS(timewindow,timenow,varargin)
% This script aggregates all data from "all" Pacific Gyre GPS transmitters that
% are specificed in BuoyData/PacificGyreInstruments.mat
% Once all data are collected, they are stored in
% BuoyData/PacificGyreGPS.mat in an array of structures where each element 
% in that array would correspond to each Pacific Gyre GPS unit.
% Within each structure, there are five field:
%          CommID: IMEI number to identify the GPS unit
%    DataDateTime: MATLAB date of GPS location
%     GPSLatitude: List of latitude values of GPS Unit
%    GPSLongitude: List of longitude values of GPS Unit
%      gpsQuality: Quality of the GPS location transmitted by the unit
%
% This script aggregate GPS data within the 1/2 day window from the current
% time. If there isn't a valid position, then DataDateTime, GPSLatitude,
% GPSLongitude, gpsQuality would be empty arrays. Use that as a check for
% valid positons during the time window.
%
% This script does not return any values. Instead, it saves all outputs to 
% BuoyData/PacificGyreGPS.mat
%
% If you have any questions or updates please contact San Nguyen at
% snguyen@opg1.ucsd.edu.
%
% Written: 2011 12 San Nguyen snguyen@opg1.ucsd.edu
% Updated: 2012 09 17 San Nguyen snguyen@opg1.ucsd.edu

% write all Pacific Gyre data to local machine 

load('BuoyData/PacificGyreInstruments.mat');
load('BuoyData/PacificGyreGPS.mat'); 

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


% acquiring data
for i = 1:numel(PacificGyreInstruments.IMEI)
    try
        PacificGyreGPS(i) = acPacGyreGPS(PacificGyreInstruments.IMEI{i},...
            'startDate',datestr(datepre,'yyyy/mm/dd HH:MM'),'endDate',datestr(timenow,'yyyy/mm/dd HH:MM'),...
            'CommID','DataDateTime','GPSLatitude','GPSLongitude','gpsQuality');
    catch err
        fprintf(1,'%s: An error occured in getAllPacGyreGPS\n during GPS aquisition of device %d\n with IMEI: %s\n',datestr(now),i,PacificGyreInstruments.IMEI{i});
        disp(err);
        continue;
    end
end

%{
try   %PATCH FOR CSC14, TAKE OUT IF NOT USING APL WEBSITE
   gps_iop=acquireIOP;
catch err
    fprintf(1,'%s: An error occured in acquireIOP\n during acquireIOP, obviously, idiot\n',datestr(now));
    disp(err)
end

PacificGyreGPS(6).DataDateTime=flipud(gps_iop.time);
PacificGyreGPS(6).GPSLatitude=flipud(gps_iop.lat);
PacificGyreGPS(6).GPSLongitude=flipud(gps_iop.lon);
PacificGyreGPS(6).gpsQuality=3*ones(size(gps_iop.lon));

%}
%save data

try
    save('BuoyData/PacificGyreGPS.mat','PacificGyreGPS');
catch err
    fprintf(1,'%s: An error occured in getAllPacGyreGPS\n during saving GPS data\n',datestr(now));
    disp(err)
end

%{
WW_position=PacificGyreGPS;
try
    save('/Volumes/scienceparty_share/WW_positions/WW_position.mat','WW_position');
catch err
    fprintf(1,'%s: An error occured in getAllPacGyreGPS\n during saving GPS data\n',datestr(now));
    disp(err)
end


try
    save('/Volumes/scienceparty_share/WW_positions/gps_iop.mat','gps_iop');
catch err
    fprintf(1,'%s: An error occured in getAllPacGyreGPS\n during saving IOP GPS data\n',datestr(now));
    disp(err)
end

%this is an addition to append WW speed and trajectory to WW_position
name=[6 11 9 7];
dt=1;
for ii=1:length(name)
    try
        [vel,head,cum_dist]=est_traj_WW('/Volumes/scienceparty_share/WW_positions/WW_position.mat',name(ii),dt);
         WW_position(name(ii)).Vel=nanmean(vel);
         WW_position(name(ii)).Heading=nanmean(head);
        WW_position(name(ii)).Vel_Head_README=strcat({'Velocity (m/s) and Heading (from North) and calculated every '},num2str(dt),{' hour(s)'});
    catch err
        fprintf(1,'%s: An error occured in getAllPacGyreGPS\n during calulating WW speed and trajectory\n',datestr(now));
        disp(err)
    end
end

try
    save('/Volumes/scienceparty_share/WW_positions/WW_position.mat','WW_position');
catch err
    fprintf(1,'%s: An error occured in getAllPacGyreGPS\n during saving GPS data\n',datestr(now));
    disp(err)
end

try
    save('/Volumes/scienceparty_share/WW_positions/gps_iop.mat','gps_iop');
catch err
    fprintf(1,'%s: An error occured in getAllPacGyreGPS\n during saving IOP GPS data\n',datestr(now));
    disp(err)
end
clear WW_position gps_iop
%}
end