function out=RSK_structC1(in)
%function out=RSK_struct(in)

out.time=(in.data.tstamp);
out.P=in.data.values(:,3)-10.13;
out.C=in.data.values(:,1);
out.T=in.data.values(:,2);
out.P(out.P<0)=0;
out.dPdt=onedgrad(out.P,1/6);
out.S=gsw_SP_from_C(out.C,out.T,out.P);
SA=gsw_SA_from_SP(out.S,out.P,86,9);
CT=gsw_CT_from_t(SA,out.T,out.P);
out.rho=gsw_rho(SA,CT,out.P);
