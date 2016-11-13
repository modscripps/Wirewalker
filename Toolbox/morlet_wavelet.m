function [cwt,scales,conversion,coi]=morlet_wavelet(x,dt,w0,Freq)

% x is the time serie to decompose
% Fs sampling frequency in cycle per hour
% w0 coef for wavelet usually w0=6
% Freq is the frequencies used fro the decomposition
% from sturla molden matlab forum
% https://cn.mathworks.com/matlabcentral/newsreader/view_thread/42824

if nargin<4
    Freq=[];
end
% Pad signal with zeros to avoid wrap-around
n = length(x);
j = ceil(log2(n));
x2 = zeros(2^j,1);
x2(1:n) = x;

% Transform to Fourier space for fast convolution
N = length(x2);
Xk = fft(x2);


% Make an angular frequency array
k = 1:N;
index1 = find(k <= N/2);
index2 = find(k > N/2);
w = k;
w(index1) = 2*pi*k(index1)/N/dt;
w(index2) = - 2*pi*k(index2)/N/dt;

% Automatic scale selection (e.g. for Wavelet denoising)
conversion = (4*pi)/(w0 + sqrt(2 + w0.^2));
if (isempty(Freq) == 1)
%     Nyquist = Fs/2;
%     s0 = 1./(Nyquist*conversion); % smallest scale = Nyquist
    s0 =  2*dt*conversion; % smallest scale = Nyquist
    dj = .25;
%    dj = .1;
%    J = log2(N/(Fs*s0))/dj;
    J = log2(N*dt/s0)/dj;
    j = 0:J;
    scales = s0 * 2.^(j*dj);
    
    % Predefined frequency grid (e.g. for TF analysis)
else
    scales = 1./(Freq*conversion);
end

scales = scales';

% Compute wavelet transform
m = length(scales);
cwt = ones(m,N);
for trials = 1:m
    s = scales(trials);
    mother = (pi^-0.25).*(w>0).*exp(-(s*w - w0).^2./2);
    daughter = sqrt(2*pi*s/dt)*mother;
    Wn = ifft(Xk.*daughter');
    cwt(trials,:) = Wn';
end

% Ignore paddes zeros
cwt = cwt(:,1:n);

coi=(1:n)*0;
coi(1)=exp(-5);coi(end)=exp(-5);
if rem(n,2)==1
    coi(fix(n/2+1):(n-1)) = (fix(n/2):-1:1);
else
    coi(fix(n/2):(n-1)) = (fix(n/2):-1:1);
end
coi    = conversion/sqrt(2)*dt*coi;
scales;
end


