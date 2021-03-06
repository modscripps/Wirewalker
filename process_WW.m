%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        - process Wirewalker - From D.Lucas previous routine  
%   pre step : get the name of the WireWalker (WW)
%              get path to data 
%              addpath to routines needed.
%              if needed create directory for figures checking
%   1 - read the rbr data (~ CTD) 
%   2 - add the trajectory of the WW
%
%  
%  written by D.Lucas
%  update  A Le Boyer 10/27/16

%% pre step 
%              get the name of the WireWalker (WW)
fprintf('Start Process %s\n',WW_name)

%              if needed create directory for figures checking
if exist(fullfile([ root_script '/FIGURES/'],WW_name),'dir')==0
    eval(['!mkdir ' fullfile([root_script '/FIGURES/'],WW_name)])
end
figure_path=fullfile([root_script '/FIGURES/'],WW_name);
disp('Add figures path')

%% set up the vertical grid 
zgrid=input('set up the vertical grid (default: 0:.25:110):\n','s');
if isempty(zgrid)
    zgrid=0:.25:110;
else
    eval(['zgrid=' zgrid ';'])
end
%% get into WW_name data
rbrfile=dir(fullfile(root_data,rbrpath,'*.rsk'));
if length(rbrfile)>2;
    fprintf('Watch out \nThere is more than one rsk file\n')
    for j=1:length(filedir); disp(rbrfile(j).name);end
end
fprintf('read rbr file is %s\n',rbrfile(1).name)

disp('RSK_wrapper--- It is may take a while --- coffee time buddy?')
[WWrbr, WWrbrraw]=RSK_wrapper(fullfile(root_data,rbrpath,rbrfile(1).name),'m',zgrid);% RSK routines from nortek
disp('Boom DONE....')
save(fullfile(root_data,rbrpath,[rbrfile(1).name '.mat']),'WWrbr','WWrbrraw')

%% put rbr data in struct ctd
ctd=WWrbr.std_profiles;

%% Set up physical param
g      = 9.81;
rho0   = nanmedian(ctd.rho(:));
rhomin = round(nanmin(ctd.rho()));
rhomax = round(nanmax(ctd.rho()));
incr   = 0.2;

%% add positions of WW_name
if exist(fullfile(root_data,'ww_pos_all.mat'),'file')
    moored_WW=0;
    fprintf('Add %s trajectory\n',WW_name)
    load(fullfile(data_dir,'ww_pos_all.mat'))
    cube_pos(:,1)=PacificGyreGPS(7).GPSLongitude;
    cube_pos(:,2)=PacificGyreGPS(7).GPSLatitude;
    cube_pos(:,3)=PacificGyreGPS(7).DataDateTime;
    
    lon=cube_pos(PacificGyreGPS(7).gpsQuality==3,1);
    lat=cube_pos(PacificGyreGPS(7).gpsQuality==3,2);
    time1=cube_pos(PacificGyreGPS(7).gpsQuality==3,3);
    
    ctd.lat=interp1(time1,lat,ctd.time)';
    ctd.lon=interp1(time1,lon,ctd.time)';
    
    clear dist1
    % filt trajectory
    fc=4; %4 cpd
    Nb=4; % order of filter
    dtb=nanmean(diff(ctd.time)); % sample interval
    fnb=1/(2*dtb)  ;        % nyquist freq
    [b, a]   = butter(Nb,fc/fnb,'low');
    ctd.latfilt=filtfilt(b,a,ctd.lat);
    ctd.lonfilt=filtfilt(b,a,ctd.lon);
    
    [dist1,az]=m_lldist_az(ctd.lonfilt, ctd.latfilt);
    dist1=[0 dist1'];
    az=[0 az'];
    dist1=cumsum(dist1);
    
    ctd.dist=dist1;
    ctd.vel=nan(size(ctd.dist));
    ctd.vel(2:end)=diff(ctd.dist*1000)./(diff(ctd.time')*86400);
    ctd.vel(1)=ctd.vel(2);
    ctd.n_drift=ctd.vel.*cosd(az);
    ctd.e_drift=ctd.vel.*sind(az);
    
    ctd.n_drift=conv2(ctd.n_drift,gausswin(12)'./sum(gausswin(12)),'same');
    ctd.e_drift=conv2(ctd.e_drift,gausswin(12)'./sum(gausswin(12)),'same');
else
    ctd.n_drift=0.*ctd.time.';
    ctd.e_drift=0.*ctd.time.';
end
%% Compute evolution of Isopycnal and project quantities on this isopycnal
% find depths and displacements of a few selected isopycnals
disp('find depths and displacements of a few selected isopycnals')
[ctd.z_iso,ctd.eta,ctd.iso]=isopycnals(ctd.rho,ctd.P,rhomin:incr:rhomax);
% find the temperature, salinity, and DO on each of those isopycnals
disp('find the temperature, salinity, and DO on each of those isopycnals')
[ctd.t_iso,ctd.s_iso,ctd.DO_iso]=calc_iso_scalars(ctd.z_iso,ctd.P,ctd.T,ctd.S,ctd.v1);

%% compute N2
%calc N2
disp('Compute N2')
[m,n]=size(ctd.T);
ctd.N2=nan(m,n);
for ii=1:n
    id=find(~isnan(ctd.rho(:,ii)));
    if length(id)>5 % need more than 5 rho data
        dz=ddz(ctd.P(id));
        ctd.N2(id,ii)=9.8/1022.*(dz*ctd.rho(id,ii));
    else
        ctd.N2(:,ii)=nan;
    end
end

%% get aqd data
[tok,rem]=strtok(WW_name,'_');
aqd_name=[tok rem(2:end)];
fprintf('Get into Aquadop %s-%s data \n',WW_name)
% do not forget to run prelim_proc_aqdll_interp_pitch
aqdfile=dir(fullfile(root_data,aqdpath,[name_aqd '.mat']));
load(fullfile(root_data,aqdpath,aqdfile.name));
eval(['Data_aqd=' name_aqd ';']);


%% dealing with time off set between rbr and aqd
disp('dealing with time off set between rbr and aqd "by hand" ')
T=length(Data_aqd.Burst_MatlabTimeStamp);
P_rbr_on_aqdtime=interp1(WWrbr.time(~isnan(WWrbr.P)), ...
    WWrbr.P(~isnan(WWrbr.P)), ...
    Data_aqd.Burst_MatlabTimeStamp);
close
plot(Data_aqd.Burst_MatlabTimeStamp,Data_aqd.Burst_Pressure,'b');hold on;
plot(Data_aqd.Burst_MatlabTimeStamp,P_rbr_on_aqdtime,'r');hold on;
title('Watch out for aqd rbr difference')
s=input('difference between aqd pressure and rbr pressure \n' ,'s');
if str2double(s)~=0
    close;
    P_rbr_on_aqdtime=P_rbr_on_aqdtime+str2double(s);
    plot(Data_aqd.Burst_MatlabTimeStamp,Data_aqd.Burst_Pressure,'b');hold on;
    plot(Data_aqd.Burst_MatlabTimeStamp,P_rbr_on_aqdtime,'r');hold on;
end

print('up_down_P_aqd_nointerp.png','-dpng')
xlim([Data_aqd.Burst_MatlabTimeStamp(fix(T/2))-40/1440,...
    Data_aqd.Burst_MatlabTimeStamp(fix(T./2))+40/1440])
title('Select precisely the red then blue crest','fontsize',25)
[X,Y]=ginput(2);
time_diff=diff(X);
% ask if figure ok? 
close


%%  Deal with strange MatlabTimeStamp
disp('dealing with wrong MatlabTime step on aqd data')
deltat       = diff(Data_aqd.Burst_MatlabTimeStamp);
%% find weird delta time sample, arbitrary criteria
%aqd_time_nok = find(deltat<6e-7|deltat>8e-7);
%% find longest period without problem
%aqd_time_ok  = find(diff(aqd_time_nok)==max(diff(aqd_time_nok)));
%aqd_time_ok  = aqd_time_nok(aqd_time_ok)+1:aqd_time_nok(aqd_time_ok+1)-1;
aqd_time_ok  = 1:length(Data_aqd.Burst_MatlabTimeStamp);


%% interp aqd data on rbr time
disp('interp aqd velocities beamamp and beamcorrel on rbr time')
P=Data_aqd.Burst_Pressure(aqd_time_ok); %this is to edit for so weird/bad time stamps at the beginning and end of the aqdII record
trim_t=Data_aqd.Burst_MatlabTimeStamp(aqd_time_ok)-time_diff;
trim_e=Data_aqd.Burst_VelEast(aqd_time_ok);
trim_n=Data_aqd.Burst_VelNorth(aqd_time_ok);
trim_u=Data_aqd.Burst_VelUp(aqd_time_ok);
trim_amp=nanmean([Data_aqd.Burst_AmpBeam1(aqd_time_ok),...
    Data_aqd.Burst_AmpBeam2(aqd_time_ok),...
    Data_aqd.Burst_AmpBeam3(aqd_time_ok),...
    Data_aqd.Burst_AmpBeam4(aqd_time_ok)],2);
trim_correl=nanmean([Data_aqd.Burst_CorBeam1(aqd_time_ok),...
    Data_aqd.Burst_CorBeam2(aqd_time_ok),...
    Data_aqd.Burst_CorBeam3(aqd_time_ok),...
    Data_aqd.Burst_CorBeam4(aqd_time_ok)],2);


%check here to make sure there isn't some horrible offset between aqdII
%pressure and the CTD pressure.
WWrbr.P_aqd=interp1(trim_t,P-str2double(s),WWrbr.time);
plot(WWrbr.time,WWrbr.P_aqd,'b');hold on;
plot(WWrbr.time,WWrbr.P,'r');hold off;
legend('AQD','RBR')
title('AQD and RBR Pressure ','fontsize',25)
print('aqd_rbr_P.png','-dpng')
close


WWrbr.e_aqd=medfilt1(interp1(trim_t,trim_e,WWrbr.time),10);
WWrbr.n_aqd=medfilt1(interp1(trim_t,trim_n,WWrbr.time),10);
WWrbr.u_aqd=medfilt1(interp1(trim_t,trim_u,WWrbr.time),10);
WWrbr.amp_aqd=medfilt1(interp1(trim_t,trim_amp,WWrbr.time),10);
WWrbr.Cor_aqd=medfilt1(interp1(trim_t,trim_correl,WWrbr.time),10);

ctd.aqd=make_standard_profiles_AQDII(WWrbr,WWrbr.idx,zgrid); 
ctd.e_abs=ctd.aqd.e+repmat(ctd.e_drift,m,1);
ctd.n_abs=ctd.aqd.n+repmat(ctd.n_drift,m,1);
ctd.u_abs=ctd.aqd.u;

WWrbr.std_profiles=ctd;

eval([name '=WWrbr;']);
eval([name '_raw=WWrbrraw;']);

save(sprintf('%s%s%s.mat',root_data,rbrpath,name),name)
save(sprintf('%s%s%s_raw.mat',root_data,rbrpath,name),[name '_raw'])



