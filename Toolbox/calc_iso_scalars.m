function [t_iso,s_iso,DO_iso]=calc_iso_scalars(z_iso,P,T,S,DO)

%this function uses the output of isopycnals.m to calculate the T, S, and
%DO on each isopycnal in the timeseries. inputs are z_iso from isopycnals,
%and matrix of T, S, and, DO, all of which have to have same number of
%columns of z_iso, and P, which has to have the same number of rows as T,S,DO.
%interpolation is used.

[m,n]=size(z_iso);
t_iso=nan(m,n);
s_iso=t_iso;
DO_iso=t_iso;

for i=1:m
    good=find(~isnan(z_iso(i,:)));
    if length(good)/m < 0.25; continue; end
    for j=1:n
        good1=find(~isnan(T(:,j)));
        if length(good1)>2
            t_iso(i,j)=interp1(P(good1),T(good1,j),z_iso(i,j));
            s_iso(i,j)=interp1(P(good1),S(good1,j),z_iso(i,j));
            DO_iso(i,j)=interp1(P(good1),DO(good1,j),z_iso(i,j));
        end
    end
end

