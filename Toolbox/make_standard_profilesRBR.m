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
fields=fieldnames(in);
for ii=1:length(indx)
    P_temp=interp_sort(in.P(indx(ii,1):indx(ii,2)));
    for f=1:length(fields)
        wh_field=fields{f};
        if (~strcmp(wh_field,'P') && ~strcmp(wh_field,'time'))
            std_profiles.(wh_field)(:,ii)=interp1(P_temp,...
                                      in.(wh_field)(indx(ii,1):indx(ii,2)),...
                                      P_vec);
        end
    end
end
        

