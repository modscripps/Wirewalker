function SetUpEmilyPacificGyreInstruments()
% This function should be ran to set up the Pacific Gyre Instruments
EmilyPacificGyreInstruments = struct(...
    'DeviceName',{{'PG13'}},... %                                    01
    'DeviceType',{{'Orange Balloon'}},... % may be a little descriptions???      01}},... %                                  11
    'IMEI',{{'300234061873830'}}); % do not change this.... 01
save('BuoyData/EmilyPacificGyreInstruments.mat','EmilyPacificGyreInstruments');
end