% prelim processing of the AQDII data from eazy-e

%load and transform aqdII data
%dirName=['/Users/drew/ASIRI/ASIRI3/cruise/WW/eazy_e/aqd/'];
%dirName=[root '/asiri3_ww/WW/ice_cube/d1/aqd/'];

eval(sprintf('cd %s',dirName))
disp(pwd)
f=dir('*ad2cp*.mat');
fprintf('be carefull at the order of file \n in dir(%s*ad2cp*.mat)',dirName)
fbis=f;
if strcmp(newname,'icecube_d1_aqd')
    % only for icecube
    fbis(1:3)=f(3:5);fbis(4:5)=f(1:2);
end

load([dirName fbis(1).name])
[Data1,~,~]=signatureAD2CP_beam2xyz_enu_interp_prh(Data, Config,'burst');
eval([newname '=Data1']);

for ii=2:length(f)
load([dirName fbis(ii).name])
[temp,~,~]=signatureAD2CP_beam2xyz_enu_interp_prh(Data, Config,'burst');
eval([newname '=mergefields(' newname ',temp,1,1)']);
end
save([newname '.mat'],newname, '-v7.3')

