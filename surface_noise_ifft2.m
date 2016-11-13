%% surface_noise_moving_shaped_ifft

addpath('../asiri3_ww/position_scripts/');
data_dir='~/ARNAUD/SCRIPPS/WireWalker/asiri3_ww/WW/';
print_dir= '../FIGURES/';
WW_name='d1';
load([data_dir 'ice_cube/d1/rbr/icecube_d1.mat'])

ctd=icecube_d1.std_profiles;

u=ctd.e_abs;
v=ctd.n_abs;
p=ctd.P;
yday=ctd.time;
[Z,T]=size(u);

if (any(sum(isnan(u),1)<=0.2*Z)>0 && any(sum(isnan(u),2)<=0.1*T)>0)
    p=p(sum(isnan(u),2)<=0.1*T);
    u=u(sum(isnan(u),2)<=.1*T,sum(isnan(u),1)<=.2*Z);
    v=v(sum(isnan(v),2)<=.1*T,sum(isnan(v),1)<=.2*Z);
    yday=yday(sum(isnan(u),1)<=.2*Z);
else
    disp(['not enough data in mooring' mooring])
end
Velo=complex(u,v);
Velo=arrayfun(@(x) fixgaps(Velo(x,:)),1:size(Velo,1),'Un',0); % fill the gap in the time serie
Velo=cell2mat(Velo.');                                        % should be little gaps
Velo=Velo(:,sum(isnan(Velo),1)==0); % get rid of edges problems
yday=yday(sum(isnan(Velo),1)==0);
[Z,T]=size(Velo);

dz=mean(diff(p));
dt=mean(diff(yday))*86400;
crit_dt=6*3600;
crit_dz=15;
filt_Velo=filtifft2(Velo,dz,dt,crit_dt,crit_dz);


%check plot

% figure
% subplot(211)
% imagesc(real(Velo))
% caxis([-.8 .8])
% subplot(212)
% imagesc(real(filt_Velo))
% caxis([-.8 .8])
% colormap('jet')
% %print('../FIGURES/ifft2_data.png','-dpng2')

shear=diff(Velo,1,1)./repmat(diff(p),[T 1]).';
filt_shear=diff(filt_Velo,1,1)./repmat(diff(p),[T 1]).';

figure
subplot(211)
imagesc(datenum2yday(yday),z,real(shear))
ylabel('Depth (m)')
caxis([-.05 .05])
title('observed shear')
set(gca,'fontsize',15)
subplot(212)
imagesc(datenum2yday(yday),z,real(filt_shear))
xlabel('yday')
ylabel('Depth (m)')
caxis([-.05 .05])
title('dz cutoff=15 m dt | cutoff=2 hours')
colormap('jet')
set(gca,'fontsize',15)

print('../FIGURES/profil_ifft2_filt_shear_1.png','-dpng2')

%save([data_dir 'ice_cube/d1/rbr/icecube_d1_ALB.mat'],'icecube_d1')

