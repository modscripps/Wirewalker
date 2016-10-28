function out=RSK_struct(in)
%function out=RSK_struct(in)

sensor={'Conductivity','Temperature','Pressure','Dissolved','Chlorophyll',...
        'CDOM','Turbidity','Sea pressure','Depth','Salinity'};
for c=1:length(in.channels)-1 % pb avec aquarius hope other cruise are fine
    for s=1:length(sensor)
        if strfind(in(s))

out.time=(in.data.tstamp);
out.P=in.data.values(:,3)-10.13;
out.C=in.data.values(:,1);
out.T=in.data.values(:,2);
out.v1=in.data.values(:,4);
out.v2=in.data.values(:,5);

out.P(out.P<0)=0;
out.dPdt=onedgrad(out.P,1/6);
out.S=gsw_SP_from_C(out.C,out.T,out.P);
SA=gsw_SA_from_SP(out.S,out.P,140,-41);
CT=gsw_CT_from_t(SA,out.T,out.P);
out.rho=gsw_rho(SA,CT,out.P);
