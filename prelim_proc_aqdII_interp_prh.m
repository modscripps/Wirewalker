% prelim processing of the AQDII data from eazy-e

%load and transform aqdII data
eval(sprintf('cd %s%s',root_data,aqdpath))
disp(pwd)
f=dir('*ad2cp*.mat');
fprintf('be carefull at the order of file in dir(%s*ad2cp*.mat) \n',dirName)
beg=zeros(1,length(f));
for l=1:length(f)
  load([aqdpath f(l).name])
  beg(l)=Data.Burst_MatlabTimeStamp(1);
end
[beg,I]=sort(beg);
fbis=f(I);

load([aqdpath fbis(1).name])
[Data1,~,~]=signatureAD2CP_beam2xyz_enu_interp_prh(Data, Config,'burst');
eval([newname '=Data1']);

if length(fbis)>1
    for ii=2:length(fbis)
        load([aqdpath fbis(ii).name])
        [temp,~,~]=signatureAD2CP_beam2xyz_enu_interp_prh(Data, Config,'burst');
        eval([newname '=mergefields(' newname ',temp,1,1)']);
    end
end
save([newname '.mat'],newname, '-v7.3')

cd(root_script) 