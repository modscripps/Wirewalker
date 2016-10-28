function [z_iso,eta,isopyc]=isopycnals(rho,P,isopyc_to_find)

%function isopyc=isopycnals(rho,isopyc_to_find)

%this function takes a bunch of profiles of density, and finds the depth of
%a particular isopycnal(s) at each time step. interpolation is used. rho is
%a matrix with depth in rows and time in columns

[m,n]=size(rho);
z_iso=nan(length(isopyc_to_find),n);
P=P(:);

for i=1:n
    good=find(~isnan(rho(:,i)));
    if length(good)/m < 0.25; continue; end
    z_iso(:,i)=interp1(rho(good,i),P(good),isopyc_to_find(:));
end

eta=z_iso-repmat(nanmean(z_iso,2),1,n);  %displacement relative to the time mean depth of each isopyc over length of rho
isopyc=isopyc_to_find(:);


