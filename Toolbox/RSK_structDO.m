function out=RSK_structDO(in)
%function out=RSK_struct(in)

out.time=(in.data.tstamp);
out.P=in.data.values(:,3)-10.13;
out.C=in.data.values(:,1);
out.T=in.data.values(:,2);
out.v1=in.data.values(:,4);
out.v2=in.data.values(:,5);
out.P(out.P<0)=0;
out.S=gsw_SP_from_C(out.C,out.T,out.P);
SA=gsw_SA_from_SP(out.S,out.P,119,32);
CT=gsw_CT_from_t(SA,out.T,out.P);
out.rho=gsw_rho(SA,CT,out.P);
out.DO=rinko(out.v2,out.T,out.P,1,out.S);
out.DO_percent=rinko(out.v2,out.T,out.P,0,out.S);