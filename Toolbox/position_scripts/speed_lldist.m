function [speed,heading,cum_dist]=speed_lldist(in)

%function [speed,distance]=speed_lldist(in)
% function to calculate speed in meters per second between succesive lat
% lon point. data sound be struct with fields .lon, .lat, .time (lat/lon in
% decimal degrees, time in seconds)

lon=in.lon(:);
lat=in.lat(:);
time=in.time(:);

[~,heading]=m_lldist_az(lon,lat);

speed=m_lldist_az(lon,lat)*1000./diff(time);
cum_dist(1)=0;
temp_dist=m_lldist(lon,lat)*1000;

for i=1:length(temp_dist)
    cum_dist(i+1)=cum_dist(i)+temp_dist(i);
end

