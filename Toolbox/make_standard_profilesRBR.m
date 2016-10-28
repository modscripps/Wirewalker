function [std_profiles]=make_standard_profilesRBR(in,indx,P_vec)

% function [std_profiles]=make_standard_profiles_o2(in,indx,P_vec,isoT_vec)
% this script makes standard depth, profile by profile matrix of WW in.
% time step is the mean time of each profile.
% in = WW structure file
% indx = index of each profile produced by find_indx_profiles.m
% P_vec = pressure vector, e.g. [0:.1:50] meters
% isoT_vec = isotherm vector, e.g. [10:.25:20] deg C

std_profiles.time=mean(in.time(indx),2);
std_profiles.P=P_vec;
%std_profiles.isoT=isoT_vec;

for ii=1:length(indx)
    P_temp=interp_sort(in.P(indx(ii,1):indx(ii,2)));
    std_profiles.T(:,ii)=interp1(P_temp,in.T(indx(ii,1):indx(ii,2)),P_vec);
    if isfield(in,'v1')==1
        std_profiles.v1(:,ii)=interp1(P_temp,in.v1(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'v2')==1
        std_profiles.v2(:,ii)=interp1(P_temp,in.v2(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'v3')==1
        std_profiles.v3(:,ii)=interp1(P_temp,in.v3(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'v4')==1
        std_profiles.v4(:,ii)=interp1(P_temp,in.v4(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'C')==1
        std_profiles.C(:,ii)=interp1(P_temp,in.C(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'S')==1
        std_profiles.S(:,ii)=interp1(P_temp,in.S(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'SA')==1
        std_profiles.SA(:,ii)=interp1(P_temp,in.SA(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'CT')==1
        std_profiles.CT(:,ii)=interp1(P_temp,in.CT(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'rho')==1
        std_profiles.rho(:,ii)=interp1(P_temp,in.rho(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'dP_dt')==1
        std_profiles.dP_dt(:,ii)=interp1(P_temp,in.dP_dt(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'dPdt')==1
        std_profiles.dPdt(:,ii)=interp1(P_temp,in.dPdt(indx(ii,1):indx(ii,2)),P_vec);
    end
    
    if isfield(in,'sigma')==1
        std_profiles.sigma(:,ii)=interp1(P_temp,in.sigma(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'F_chla')==1
        std_profiles.F_chla(:,ii)=interp1(P_temp,in.F_chla(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'F_CDOM')==1
        std_profiles.F_CDOM(:,ii)=interp1(P_temp,in.F_CDOM(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'turb')==1
        std_profiles.turb(:,ii)=interp1(P_temp,in.turb(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'O2_volt')==1
        std_profiles.O2_volt(:,ii)=interp1(P_temp,in.O2_volt(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'DO')==1
        std_profiles.DO(:,ii)=interp1(P_temp,in.DO(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'DO_percent')==1
        std_profiles.DO_percent(:,ii)=interp1(P_temp,in.DO_percent(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'par')==1
        %         keyboard
        std_profiles.par(:,ii)=interp1(P_temp,in.par(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'e')==1
        %         keyboard
        std_profiles.e(:,ii)=interp1(P_temp,in.e(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'n')==1
        %         keyboard
        std_profiles.n(:,ii)=interp1(P_temp,in.n(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'e_correc')==1
        %         keyboard
        std_profiles.e_correc(:,ii)=interp1(P_temp,in.e_correc(indx(ii,1):indx(ii,2)),P_vec);
    end
    if isfield(in,'n_correc')==1
        %         keyboard
        std_profiles.n_correc(:,ii)=interp1(P_temp,in.n_correc(indx(ii,1):indx(ii,2)),P_vec);
    end
    
    
end

