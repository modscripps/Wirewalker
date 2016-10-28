function SetUp_RBR_GPS_Instruments()
% This function should be ran to set up the Pacific Gyre Instruments
RBR_GPS_Instruments = struct(...
    'DeviceName',{{'WW RBR Ice Cube'}},... % each of these should be the WW labels  01
    'DeviceType',{{'RBR GPS unit'}},... % may be a little descriptions???      01
    'DeviceID',{{'80281'}});%  do not change this                     01
save('BuoyData/RBR_GPS_Instruments.mat','RBR_GPS_Instruments');
end