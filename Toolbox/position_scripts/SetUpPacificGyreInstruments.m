function SetUpPacificGyreInstruments()
% This function should be ran to set up the Pacific Gyre Instruments
PacificGyreInstruments = struct(...
    'DeviceName',{{'WW01'; % each of these should be the WW labels  01
                   'WW02'; %                                        02
                   'WW03'; %                                        03
                   'WW04'; %                                        04
                   'WW Dr. Dre'; %                                        05
                   'ww1'; %                                        06
                   'WW Ice Cube'; %                                        07
                   'WW08'; %                                        08
                   'WW Mc Ren'; %                                        09
                   'WW10'; %                                        10
                   'WW Eazy-E'}},... %                                    11
    'DeviceType',{{'Drifter Buoy'; % may be a little descriptions???      01
                   'Drifter Buoy'; %                                      02
                   'Drifter Buoy'; %                                      03
                   'Drifter Buoy'; %                                      04
                   'Drifter Buoy'; %                                      05
                   'Drifter Buoy'; %                                      06
                   'Drifter Buoy'; %                                      07
                   'Drifter Buoy'; %                                      08
                   'Drifter Buoy'; %                                      09
                   'Drifter Buoy'; %                                      10
                   'Drifter Buoy'}},... %                                  11
    'IMEI',{{'300034013750350'; % do not change this.... 01
             '300034013751350'; %                        02
             '300034013752360'; %                        03
             '300034013753340'; %                        04
             '300034013756340'; %                        05
             '300034013757350'; %                        06
             '300034013758340'; %                        07
             '300034013759340'; %                        08
             '300034012390340'; %                        09
             '300034012390350'; %                        10
             '300034012392340'}});%                       11
save('BuoyData/PacificGyreInstruments.mat','PacificGyreInstruments');
end