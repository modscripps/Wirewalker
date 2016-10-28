function SetUp_SparBuoy_GPS_Instruments()
% This function should be ran to set up the Drifter Buoy for ASIRI 2015
ASSETS = load('/Volumes/OPG Mini/ASIRI/2015/ScienceShare/solo/assets_positions.mat');
ASSETS = ASSETS.ASSETS;

a = find(ASSETS.id == 300234062029420);

[ID,I] = unique(ASSETS.id(a));

b = a(I);

SparBuoy_GPS_Instruments = struct(...
    'DeviceName',{cell(size(ASSETS.type(b)))},... % each of these should be the WW labels  01
    'DeviceType',{ASSETS.type(b)},... % may be a little descriptions???      01
    'DeviceID',{cell(size(ASSETS.type(b)))});%  do not change this                     01

for i = 1:numel(SparBuoy_GPS_Instruments.DeviceType)
    SparBuoy_GPS_Instruments.DeviceID{i} = num2str(ID(i));
    SparBuoy_GPS_Instruments.DeviceName{i} = ['Spar Buoy ' SparBuoy_GPS_Instruments.DeviceID{i}(end-4:end)];
end

save('BuoyData/SparBuoy_GPS_Instruments.mat','SparBuoy_GPS_Instruments');

end