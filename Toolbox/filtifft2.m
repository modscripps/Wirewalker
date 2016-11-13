%% surface_noise_moving_shaped_ifft
function filt_field=filtifft2(field,dz,dt,crit_dt,crit_dz)

[Z,T]=size(field);
hat_field=fft2(field);

% %windowT=gausswin(T);windowZ=gausswin(Z);
% windowT=ones(T,1);windowZ=gausswin(Z);
% window=windowZ*windowT';

dk=(1/Z)/dz;
if rem(Z,2)==0
k=-Z/2*dk:dk:Z/2*dk-dk;
else
	kp=dk:dk:dk*floor(Z/2);	k=[fliplr(-kp) 0 kp];
end

df=(1/T)/dt;
if rem(T,2)==0
freq=-T/2*df:df:T/2*df-df;
else
	om=df:df:df*floor(T/2);	freq=[fliplr(-om) 0 om];
end

[ff,kk]=meshgrid(fftshift(freq),fftshift(k));
crit_ff=1/crit_dt;
crit_kk=1/crit_dz;
flag_ff=abs(ff)<crit_ff;
flag_kk=abs(kk)<crit_kk;

flag=flag_ff & flag_kk;

%filter 2D_spectrum
filt_hat_field=hat_field;
filt_hat_field(~flag)=0;


filt_field=ifft2(filt_hat_field);

