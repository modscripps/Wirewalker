%% This is set up for icecube_d1
%  take care of the variable names for another cruise
% The name definition is still under progress. Depending on the cruise, we
% do not have the same structure. some looks like
% WW/name_of_the_wirewalker/d1/aqd
% other looks like 
% WW/name_of_the_wirewalker/aqd

root_data='/Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/';
root_script='/Users/aleboyer/Desktop/Wirewalker-master/';
Cruise_name='quipp'; % 
WW_name='quipp'; % 
deployement='d1';

aqdpath=sprintf('%s/WW/%s/%s/aqd/',Cruise_name,WW_name,deployement);
rbrpath=sprintf('%s/WW/%s/%s/rbr/',Cruise_name,WW_name,deployement);

newname='tuto_aqd';

% used in prelim_proc_aqdII_interp_prh;
% path to aquadopp data.

% adding path 
addpath([root_script 'Toolbox']);
addpath([root_script 'Toolbox/mksqlite-1.12-src']);
addpath([root_script 'Toolbox/gsw_matlab_v3_02']);
addpath([root_script 'Toolbox/gsw_matlab_v3_02/library']);
addpath([root_script 'Toolbox/position_scripts']);


% used in process_WW should be the name after the folder WW in dirName ;


prelim_proc_aqdII_interp_prh;
process_WW;
wavelet_filter_v3;

