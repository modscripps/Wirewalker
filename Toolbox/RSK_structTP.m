function out=RSK_structTP(in)
%function out=RSK_struct(in)

out.time=(in.data.tstamp);
out.P=in.data.values(:,2)-10.13;
out.T=in.data.values(:,1);
out.P(out.P<0)=0;
out.dPdt=onedgrad(out.P,1/6);
