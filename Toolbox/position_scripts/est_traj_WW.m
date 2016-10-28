function [vel,head,cum_dist]=est_traj_WW(pos_file,name,dt)

% function [vel,head]=est_traj_WW(pos_file,name,dt)
%assuming here time is in ten minute increments and dt is in hours

F=load(pos_file);
N=fieldnames(F);
pos=F.(N{1});
time=1:6*dt;
if length(time)>length(pos(name).GPSLongitude)
    time=1:length(pos(name).GPSLongitude);
end

in.lon=pos(name).GPSLongitude(time);
in.lat=pos(name).GPSLatitude(time);
in.time=timechange(pos(name).DataDateTime(time)); %turn matlabtime into seconds

in.lon=flipud(in.lon(:));
in.lat=flipud(in.lat(:));
in.time=flipud(in.time(:));

[vel,head,cum_dist]=speed_lldist(in);