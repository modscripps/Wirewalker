function out=RSK_structM(in)
%function out=RSK_structM(in)

out.time=(in.data.tstamp)';
out.P=in.data.values(:,3)-10.13;
out.C=in.data.values(:,1);
out.T=in.data.values(:,2);
out.v2=in.data.values(:,5);
out.v1=in.data.values(:,4);
out.v3=in.data.values(:,6);
out.v4=in.data.values(:,7);


out.P(out.P<0)=0;
out.dPdt=onedgrad(out.P,1/6);
out.S=gsw_SP_from_C(out.C,out.T,out.P);
SA=gsw_SA_from_SP(out.S,out.P,86,9);
CT=gsw_CT_from_t(SA,out.T,out.P);
out.rho=gsw_rho(SA,CT,out.P);
out.sig0=gsw_sigma0(SA,CT);
