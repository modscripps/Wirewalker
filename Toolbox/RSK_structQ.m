function out=RSK_structQ(in)
%function out=RSK_struct(in)

i=0;
for c=1:length(in.channels) % pb avec aquarius hope other cruise are fine
    switch c
        case 4
            out.P=in.data.values(:,c)-10.13;
        case 9
            out.P1=in.data.values(:,c);
        case 10
            out.P2=in.data.values(:,c);
        case 2
            out.C=in.data.values(:,c);
        case 3
            out.T=in.data.values(:,c);
        case 11
            out.S1=in.data.values(:,c);
        otherwise
            i=i+1;
            eval(sprintf('out.v%i=in.data.values(:,c);',i));
    end
end
out.time=(in.data.tstamp);
out.P(out.P<0)=0;
out.dPdt=onedgrad(out.P,1/6);
out.S=gsw_SP_from_C(out.C,out.T,out.P);
SA=gsw_SA_from_SP(out.S,out.P,140,-41);
CT=gsw_CT_from_t(SA,out.T,out.P);
out.rho=gsw_rho(SA,CT,out.P);
