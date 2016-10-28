function [std_profiles]=make_standard_profiles_AQDII(in,indx,P_vec)

% function [std_profiles]=make_standard_profiles_o2(in,indx,P_vec,isoT_vec)
% this script makes standard depth, profile by profile matrix of WW data.
% time step is the mean time of each profile.
% in = WW structure file
% indx = index of each profile produced by find_indx_profiles.m
% P_vec = pressure vector, e.g. [0:.1:50] meters
% isoT_vec = isotherm vector, e.g. [10:.25:20] deg C

std_profiles.time=mean(in.time(indx),2);
std_profiles.P=P_vec;
% std_profiles.isoT=isoT_vec;

for ii=1:length(indx)
    
    [Psort,id]=sort(in.P(indx(ii,1):indx(ii,2)),'descend');
    etemp=in.e_aqd(indx(ii,1):indx(ii,2));
    ntemp=in.n_aqd(indx(ii,1):indx(ii,2));
    utemp=in.u_aqd(indx(ii,1):indx(ii,2));
    etemp=etemp(id);
    ntemp=ntemp(id);
    utemp=utemp(id);
    
    P_temp=(interp_sort(Psort));
    std_profiles.e(:,ii)=interp1(P_temp,etemp,P_vec);
    std_profiles.n(:,ii)=interp1(P_temp,ntemp,P_vec);
    std_profiles.u(:,ii)=interp1(P_temp,utemp,P_vec);
    if isfield(in,'dPdt')
        std_profiles.dPdt(:,ii)=interp1(P_temp,in.dPdt(indx(ii,1):indx(ii,2)),P_vec);
    end
    %     std_profiles.P_isoT(:,ii)=interp1(isoT_temp,in.P(indx(ii,1):indx(ii,2)),isoT_vec);
    %     std_profiles.F_isoT(:,ii)=interp1(isoT_temp,in.F_chla(indx(ii,1):indx(ii,2)),isoT_vec);
    
end
