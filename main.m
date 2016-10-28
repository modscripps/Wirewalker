%% This is set up for icecube_d1
%  take care of the variable names for another cruise
% The name definition is still under progress. Depending on the cruise, we
% do not have the same structure. some looks like
% WW/name_of_the_wirewalker/d1/aqd
% other looks like 
% WW/name_of_the_wirewalker/aqd

root='/Users/aleboyer/ARNAUD/SCRIPPS/WireWalker';
root_script='~/Github/Wirewalker/';


% used in prelim_proc_aqdII_interp_prh;
dirName=[root '/asiri3_ww/WW/ice_cube/d1/aqd/'];
newname='icecube_d1_aqd'; % can be whatever you want

% adding path 
addpath([root_script 'Toolbox']);
addpath([root_script 'Toolbox/mksqlite-1.12-src']);
addpath([root_script 'Toolbox/gsw_matlab_v3_02']);
addpath([root_script 'Toolbox/gsw_matlab_v3_02/library']);
addpath([root_script 'Toolbox/position_scripts']);


% used in process_WW should be the name after the folder WW in dirName ;
WW_name='ice_cube'; % 


prelim_proc_aqdII_interp_prh;
process_WW;
wavelet_filter_v3;

