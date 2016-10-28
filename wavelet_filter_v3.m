% load  '~/ARNAUD/SCRIPPS/WireWalker/asiri3_ww/WW/ice_cube/d1/rbr/icecube_d1.mat'
% addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/scripts/processing/
% some coding tricks
check=0;

% rename some variable 
nu=icecube_d1.n_aqd;eu=icecube_d1.e_aqd;uu=icecube_d1.u_aqd;
tu=icecube_d1.time;Pu=icecube_d1.P;


%% cells of upcasts 
ncell=arrayfun(@(x) nu(icecube_d1.idx(x,1):icecube_d1.idx(x,2)),1:length(icecube_d1.idx),'un',0);
ecell=arrayfun(@(x) eu(icecube_d1.idx(x,1):icecube_d1.idx(x,2)),1:length(icecube_d1.idx),'un',0);
ucell=arrayfun(@(x) uu(icecube_d1.idx(x,1):icecube_d1.idx(x,2)),1:length(icecube_d1.idx),'un',0);
Velocell=cellfun(@(x,y) complex(x,y),ecell,ncell,'un',0);
time=arrayfun(@(x) tu(icecube_d1.idx(x,1):icecube_d1.idx(x,2)),1:length(icecube_d1.idx),'un',0);
Press=arrayfun(@(x) Pu(icecube_d1.idx(x,1):icecube_d1.idx(x,2)),1:length(icecube_d1.idx),'un',0);

% some parameters 
w0   = 6.; % for the wavelet
dt=mean(diff(icecube_d1.time))*86400;
Fs=dt;

N=cellfun(@length,Velocell,'un',0); % get length of all upcast
mu=cellfun(@mean,Velocell,'un',0);  % get the mean of all upcast
mu_up=cellfun(@mean,ucell,'un',0);  % get the mean of all upcast
Velop=cellfun(@(x,y) x-y,Velocell,mu,'un',0); % remove the mean of all upcast
Vel_upp=cellfun(@(x,y) x-y,ucell,mu_up,'un',0); % remove the mean of all upcast

% compute wavelet decomposition for the real and imaginary part of the
% velocities. I have to do it in 2 times (real and imaginary) since my
% wavelet decomposition applied only on the positive part of the fourrier
% transform thus would decompose/extract the clockwise (in time) part of Velop
[rcwt,~,~,~]=cellfun(@(x) morlet_wavelet(real(x),Fs,w0,[]),Velop,'un',0); 
[icwt,scales,conversion,coi]=cellfun(@(x) morlet_wavelet(imag(x),Fs,w0,[]),Velop,'un',0);
[ucwt,~,~,~]=cellfun(@(x) morlet_wavelet(x,Fs,w0,[]),Vel_upp,'un',0);

% reconstruct the signal. I tuned a little bit with my .62 coef to make it 
% close to the original signal there is most likely a proper way to do it 
% check D. rudnick wavelet routines
Cs=0.7784;r0=0.7511;%from theory
ds=cellfun(@(x) nanmean(diff(x)),scales,'un',0);
recons_coef=cellfun(@(x,y) (x*sqrt(dt)/Cs/r0./sqrt(y)),ds,scales,'un',0);

r_recons_signal=cellfun(@(x,y,z)...
                         (.60*repmat(x,[1,z]).*abs(y).*cos(angle(y))),...
                         recons_coef,rcwt,N,'un',0);
i_recons_signal=cellfun(@(x,y,z)...
                         (.60*repmat(x,[1,z]).*abs(y).*cos(angle(y))),...
                         recons_coef,icwt,N,'un',0);
u_recons_signal=cellfun(@(x,y,z)...
                         (.60*repmat(x,[1,z]).*abs(y).*cos(angle(y))),...
                         recons_coef,ucwt,N,'un',0);
                     

%% create block of 5 upcast and extract signal with low variability around
%  the median of this 5 upcast. 

% check make_wavelet_std_filt on the first block
%if check==1;check_make_wavelet_std_filt;end

% arg of make_wavelet_std_filt should be cells
% coef1 set up threshold of standard deviation of frequency-time velocity 
% above which we consider the signal is the surface wave signal
% coef2 set up the cut of period  
coef1 = .15;  % 15% of variance 
coef2 = 5;    % 6h filt 
dt_cast    = mean(diff(cellfun(@mean,time)))*86400;
Block_filtrcwt=make_wavelet_std_filt(r_recons_signal,scales,Press,...
                                     dt_cast,coef1,coef2);
Block_filticwt=make_wavelet_std_filt(i_recons_signal,scales,Press,...
                                     dt_cast,coef1,coef2);
Block_filtucwt=make_wavelet_std_filt(u_recons_signal,scales,Press,...
                                     dt_cast,coef1,coef2);

% reconstruct the signal. I tuned a little bit with my .62 coef to make it 
% close to the original signal there is most likely a proper way to do it 
% check D. rudnick wavelet routines
r_filtrecons_signal=cellfun(@(x,y,z)...
                           (.60*repmat(x,[1,z]).*abs(y).*cos(angle(y))),...
                           recons_coef,Block_filtrcwt,N,...
                           'un',0);
i_filtrecons_signal=cellfun(@(x,y,z)...
                           (.60*repmat(x,[1,z]).*abs(y).*cos(angle(y))),...
                           recons_coef,Block_filticwt,N,...
                           'un',0);
u_filtrecons_signal=cellfun(@(x,y,z)...
                           (.60*repmat(x,[1,z]).*abs(y).*cos(angle(y))),...
                           recons_coef,Block_filtucwt,N,...
                           'un',0);
                    
% grid the filtered velocities
velfilt=cellfun(@(x,y,z) complex(nanmean(x,1)+real(z),nanmean(y,1)+imag(z)),...
                        r_filtrecons_signal,i_filtrecons_signal,mu,'un',0);
vel_up_filt=cellfun(@(x,y) nanmean(x,1)+real(y),...
                        u_filtrecons_signal,mu_up,'un',0);

zgrid=0:.25:110;m=length(zgrid);
icecube_d1.e_aqd_filt=real([velfilt{:}]);
icecube_d1.n_aqd_filt=imag([velfilt{:}]);
icecube_d1.u_aqd_filt=[vel_up_filt{:}];

icecube_d1.std_profiles_filt=icecube_d1.std_profiles;
icecube_d1.std_profiles_filt.aqd=make_standard_profiles_AQDII_filt_surf(icecube_d1,icecube_d1.idx,zgrid); %110 max pressure d1

icecube_d1.std_profiles_filt.e_abs=icecube_d1.std_profiles_filt.aqd.e+repmat(icecube_d1.std_profiles.e_drift,m,1);
icecube_d1.std_profiles_filt.n_abs=icecube_d1.std_profiles_filt.aqd.n+repmat(icecube_d1.std_profiles.n_drift,m,1);
icecube_d1.std_profiles_filt.u_abs=icecube_d1.std_profiles_filt.aqd.u;

save(sprintf('%s/%s_%s.mat',rbrpath,aqd_name,filedir(i).name),[aqd_name '_' filedir(i).name])


%% plots

name='icecube_d1';
var='Zonal';
velfilt=icecube_d1.std_profiles_filt.e_abs(8:end,:);
vel_nofilt=icecube_d1.std_profiles.e_abs(8:end,:);
z=icecube_d1.std_profiles.P(8:end);

[Z,T]=size(velfilt);
% compute shear
z12=z(1:end-1)+0.5*diff(z);
shearfilt=diff(velfilt,[],1)./repmat(diff(z)',[1 T]);
shearnofilt=diff(vel_nofilt,[],1)./repmat(diff(z)',[1 T]);
rms_shearfilt=nanstd(shearfilt,[],2).^2;
rms_shearnofilt=nanstd(shearnofilt,[],2).^2;
cmax=.1;

data=shearnofilt;
data_flat=shearfilt;

error=sqrt((data_flat-data).^2);
errorf=error;
for k=10:size(error,1)-10
    errorf(k,:)=nanmean(error(k-9:k+9,:),1);
end

zonalerrorf=errorf;
rms_errorshear=nanstd(zonalerrorf,[],2).^2;
close all
figure(1)
i=1; 
w1=.55;w2=.01;w3=0.13;
h1=.2;
x1=.1;x2=x1+w1+.02;x3=x2+w2+.08;
y1=(4-i)*.25;

%%  plot data no filt
ax(i)=subplot('Position',[x1 y1 w1 h1]);
ax(i+3)=subplot('Position',[x3 y1 w3 h1]);
colormap('jet')
pcolor(ax(i),datenum2yday(icecube_d1.std_profiles.time),z12,data);
caxis(ax(i),[-cmax,cmax]);shading(ax(i),'flat');axis(ax(i),'ij')
ylabel(ax(i),'depth (m)','fontsize',10)
title(ax(i),[var ' Shear no surface filter'],'fontsize',10)
ylim(ax(i),[0 115]);
cax=colorbar(ax(i),'Position',[x2 y1 w2 h1]);
%cax.Limits=[-cmax,cmax];
ylabel(cax,'s^{-1}','fontsize',10)
plot(ax(i+3),rms_shearnofilt,z12),axis(ax(i+3),'ij');
ylim(ax(i+3),[0 115]);xlim(ax(i+3),[-.05 1]);
set(ax(i+3),'Yticklabel','')

%%  plot data filt
i=2;
y1=(4-i)*.25-.05;
ax(i)=subplot('Position',[x1 y1 w1 h1]);
ax(i+3)=subplot('Position',[x3 y1 w3 h1]);
colormap('jet')
pcolor(ax(i),datenum2yday(icecube_d1.std_profiles.time),z12,data_flat);
caxis(ax(i),[-cmax,cmax]);shading(ax(i),'flat');axis(ax(i),'ij')
ylabel(ax(i),'depth (m)','fontsize',10)
title(ax(i),[var ' Shear surface filter'],'fontsize',10)
ylim(ax(i),[0 115]);
cax=colorbar(ax(i),'Position',[x2 y1 w2 h1]);
%cax.Limits=[-cmax,cmax];
ylabel(cax,'s^{-1}','fontsize',10)
plot(ax(i+3),rms_shearfilt,z12),axis(ax(i+3),'ij');
ylim(ax(i+3),[0 115]);xlim(ax(i+3),[-.05 1]);
set(ax(i+3),'Yticklabel','')

%%  plot error data
i=3;
y1=(4-i)*.25-.1;
ax(i)=subplot('Position',[x1 y1 w1 h1]);
ax(i+3)=subplot('Position',[x3 y1 w3 h1]);
colormap('jet')
pcolor(ax(i),datenum2yday(icecube_d1.std_profiles.time),z12,data-data_flat);
caxis(ax(i),[-cmax,cmax]);shading(ax(i),'flat');axis(ax(i),'ij')
ylabel(ax(i),'depth (m)','fontsize',10)
title(ax(i),'error $\sqrt{(S_{filt}-S_{nofilt})^2}$','interpreter','latex','fontsize',10)
ylim(ax(i),[0 115]);
cax=colorbar(ax(i),'Position',[x2 y1 w2 h1]);
%cax.Limits=[-cmax,cmax];
ylabel(cax,'s^{-1}','fontsize',10)
plot(ax(i+3),rms_errorshear,z12),axis(ax(i+3),'ij');
ylim(ax(i+3),[0 115]);xlim(ax(i+3),[-.05 1]);
set(ax(i+3),'Yticklabel','')
xlabel(ax(i),'year day','fontsize',10)
xlabel(ax(i+3),'rms','fontsize',10)

print(sprintf('%s%s_%s_shear_wavelet_filt_v3.png','./',name,var),'-dpng');


% 
% 
% 
% 
% var='Meridional';
% velfilt=icecube_d1.std_profiles_filt.n_abs(8:end,:);
% vel_nofilt=icecube_d1.std_profiles.n_abs(8:end,:);
% %compute shear
% shearfilt=diff(velfilt,[],1)./repmat(diff(z)',[1 T]);
% shearnofilt=diff(vel_nofilt,[],1)./repmat(diff(z)',[1 T]);
% rms_shearfilt=nanstd(shearfilt,[],2).^2;
% rms_shearnofilt=nanstd(shearnofilt,[],2).^2;
% cmax=.1;
% 
%  data=shearnofilt;
%  data_flat=shearfilt;
% 
% 
% figure(2)
% 
% error=sqrt((data_flat-data).^2);
% errorf=error;
% for k=10:size(error,1)-10
%     errorf(k,:)=nanmean(error(k-9:k+9,:),1);
% end
% meridionalerrorf=errorf;
% rms_errorshear=nanstd(meridionalerrorf,[],2).^2;
% 
% i=1; 
% w1=.55;w2=.01;w3=0.13;
% h1=.2;
% x1=.1;x2=x1+w1+.02;x3=x2+w2+.08;
% y1=(4-i)*.25;
% 
% %%  plot data no filt
% ax(i)=subplot('Position',[x1 y1 w1 h1]);
% ax(i+3)=subplot('Position',[x3 y1 w3 h1]);
% colormap('jet')
% pcolor(ax(i),datenum2yday(icecube_d1.std_profiles.time),z12,data);
% caxis(ax(i),[-cmax,cmax]);shading(ax(i),'flat');axis(ax(i),'ij')
% ylabel(ax(i),'depth (m)','fontsize',10)
% title(ax(i),[var ' Shear no surface filter'],'fontsize',10)
% ylim(ax(i),[0 115]);
% cax=colorbar(ax(i),'Position',[x2 y1 w2 h1]);
% %cax.Limits=[-cmax,cmax];
% ylabel(cax,'s^{-1}','fontsize',10)
% plot(ax(i+3),rms_shearnofilt,z12),axis(ax(i+3),'ij');
% ylim(ax(i+3),[0 115]);xlim(ax(i+3),[-.05 1]);
% set(ax(i+3),'Yticklabel','')
% 
% %%  plot data filt
% i=2;
% y1=(4-i)*.25-0.05;
% ax(i)=subplot('Position',[x1 y1 w1 h1]);
% ax(i+3)=subplot('Position',[x3 y1 w3 h1]);
% colormap('jet')
% pcolor(ax(i),datenum2yday(icecube_d1.std_profiles.time),z12,data_flat);
% caxis(ax(i),[-cmax,cmax]);shading(ax(i),'flat');axis(ax(i),'ij')
% ylabel(ax(i),'depth (m)','fontsize',10)
% title(ax(i),[var ' Shear surface filter'],'fontsize',10)
% ylim(ax(i),[0 115]);
% cax=colorbar(ax(i),'Position',[x2 y1 w2 h1]);
% %cax.Limits=[-cmax,cmax];
% ylabel(cax,'s^{-1}','fontsize',10)
% plot(ax(i+3),rms_shearfilt,z12),axis(ax(i+3),'ij');
% ylim(ax(i+3),[0 115]);xlim(ax(i+3),[-.05 1]);
% set(ax(i+3),'Yticklabel','')
% 
% %%  plot error data
% i=3;
% y1=(4-i)*.25-.1;
% ax(i)=subplot('Position',[x1 y1 w1 h1]);
% ax(i+3)=subplot('Position',[x3 y1 w3 h1]);
% colormap('jet')
% pcolor(ax(i),datenum2yday(icecube_d1.std_profiles.time),z12,data-data_flat);
% caxis(ax(i),[-cmax,cmax]);shading(ax(i),'flat');axis(ax(i),'ij')
% ylabel(ax(i),'depth (m)','fontsize',10)
% title(ax(i),'error $\sqrt{(S_{filt}-S_{nofilt})^2}$','interpreter','latex','fontsize',10)
% ylim(ax(i),[0 115]);
% cax=colorbar(ax(i),'Position',[x2 y1 w2 h1]);
% %cax.Limits=[-cmax,cmax];
% ylabel(cax,'s^{-1}','fontsize',10)
% plot(ax(i+3),rms_errorshear,z12),axis(ax(i+3),'ij');
% ylim(ax(i+3),[0 115]);xlim(ax(i+3),[-.05 1]);
% set(ax(i+3),'Yticklabel','')
% xlabel(ax(i),'year day','fontsize',10)
% xlabel(ax(i+3),'rms','fontsize',10)
% linkaxes(ax,'y')
% print(sprintf('%s%s_%s_shear_wavelet_filt_v3.png','../FIGURES/',name,var),'-dpng');


% t=datenum2yday(icecube_d1.std_profiles.time);
% indt1=find(t>242 & t<242.015);
% indt2=find(t>246.5 & t<246.515);
% 
% cmap=colormap(jet(length(indt1)*100));
% cmap=cmap(1:100:length(indt1)*100,:);
% 
% figure(3)
% ax(1)=subplot('Position',[0.1,0.1,0.35,0.8]);
% ax(2)=subplot('Position',[0.5,0.1,0.35,0.8]);
% hold(ax(1),'on');%hold(ax(2),'on');
% leg=[];
% for it=indt1'
%     idx=it-indt1(1)+1;
%     leg(idx+length(indt1))=plot(ax(1),data(:,it)+2*idx-1,z12,'--','Color',cmap(idx,:));
%     leg(idx)=...
%         plot(ax(1),data_flat(:,it)+2*idx-1,z12,'-','Color',cmap(idx,:));
% end
% axis(ax(1),'ij')
% ylim(ax(1),[0,40])
% hleg=legend(leg,[num2str(t(indt1));'No Filte'],'location','SouthEast');
% set(hleg,'fontsize',15)
% %legend(leg1,'no filt')
% hold(ax(1),'off');%hold(ax(2),'off');
% 
% hold(ax(2),'on');%hold(ax(2),'on');
% leg=[];
% for it=indt2'
%     idx=it-indt2(1)+1;
%     leg(idx+length(indt2))=...
%         plot(ax(2),data(:,it)+2*idx-1,z12,'--','Color',cmap(idx,:));
%     leg(idx)=...
%         plot(ax(2),data_flat(:,it)+2*idx-1,z12,'-','Color',cmap(idx,:));
% end
% axis(ax(2),'ij')
% ylim(ax(2),[0,40])
% hleg=legend(leg,[num2str(t(indt2));'no Filte'],'location','SouthEast');
% set(hleg,'fontsize',15)
% %legend(leg1,'no filt')
% hold(ax(2),'off');%hold(ax(2),'off');
% ylabel(ax(1),'Depth (m)','fontsize',15)
% xlabel(ax(1),'Shear (s^{-1})','fontsize',15)
% xlabel(ax(2),'Shear (s^{-1})','fontsize',15)
% 
% print(sprintf('%s%s_%s_shear_profils_wavelet_filt_v3.png','../FIGURES/',name,var),'-dpng');



