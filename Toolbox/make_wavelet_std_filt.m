%function Block_filtcwt=make_wavelet_std_filt(recons_signal,cwt,Scales,Press)
function Block_filtcwt=make_wavelet_std_filt(recons_signal,Scales,Press,dt,coef1,coef2)
    % watch out the first step consist in regriding all the upcast on the same
    % map to define a time evolving filter. If great number of upcast this
    % might be pretty long. So far worked fast enough for 2414 upcast 

    switch nargin
        case 6
            disp('start surface wave filtering')
        case 5
            disp('start surface wave filtering')
            coef2=0.5;
        case 4
            disp('start surface wave filtering')
            coef2=0.5;coef1=.15;
        otherwise
            disp('missing arguments in make_wavelet_std_filt')
    end
        
    % define a filter that will extract the strong standard deviation
    % signal from the wavlet analysis. The std is define over 5 upcasts
    N=length(recons_signal);
    Smax = max(cellfun(@length,Scales));
    %S    = Scales{cellfun(@length,Scales(n-1:n+1))==Smax};
    
    % sort the original pressure. Sparse influence of surface waves rarely
    % force the upcast to not be monotically ascendant.
    [Psort,id] = cellfun(@(x) sort(x,'ascend'),Press,'un',0);
    P_temp     = cellfun(@interp_sort,Psort,'un',0);
    signal     = cellfun(@(x,y) x(:,y),recons_signal,id,'un',0);
    
    % define a fine (2000 level) vertical grid
    Pgrid      = linspace(min(vertcat(P_temp{:})),max(vertcat(P_temp{:})),2000);
    Lmax       = length(Pgrid);
    
    % interp data on  the new grid so that every upcast have the same
    % number of levels and easily compute the std between upcast at fixed
    % depth
    Block_signal = cell2mat(cellfun(@(x,y) interp1(x,y.',Pgrid).',...
        P_temp,signal,'un',0));
                      
    % prepare bloc of 5 upcast to compute the deviation
    Block_signal=reshape(Block_signal,[Smax,Lmax,N]);
    std_Block_percent=nan.*Block_signal;
    for n=3:N-2
        % compute deviation
        std_Block=std_median(squeeze(Block_signal(:,:,n-2:n+2)));
        % interpolation can introduce nans. here I simply get rid of the surface
        % and bottom
        i1=find(diff(cumsum(isnan(std_Block(1,:))))==0,1,'first');
        i2=find(diff(cumsum(isnan(std_Block(1,:))))==0,1,'last')+2;
        std_Block(:,1:i1)=repmat(std_Block(:,i1+1),[1,i1]);
        std_Block(:,i2:end)=repmat(std_Block(:,i2-1),[1,Lmax-i2+1]);
        std_Block_percent(:,:,n)=std_Block./max(std_Block(:));
    end
    std_Block_percent(:,:,1)=std_Block_percent(:,:,3);
    std_Block_percent(:,:,2)=std_Block_percent(:,:,3);
    std_Block_percent(:,:,N-1)=std_Block_percent(:,:,N-2);
    std_Block_percent(:,:,N)=std_Block_percent(:,:,N-2);
    
    
    % define the mask for filter with a criteria on the intensity of the
    % standard deviation arbitrary 10%. These indices will be set at nan in
    % the next
    mask=double(std_Block_percent>=coef1);

    % define lowest scale and the depth (in indices) of the main surface
    % wave signal (define just above). These two caracteristics will define
    % the 2 strait line in the wavelet space above which the signal will be
    % set to 0
    depth_surface_wave = squeeze(max(sum(mask,2)));

    % filter the time serie of the depth of the surface wave
    fc=1/coef2/3600;       % coef2 in hour
    fnb=1/(2*dt)  ;        % nyquist freq , dt in s
    [b, a]   = butter(3,fc/fnb,'low');
    filt_depth_surface_wave=ceil(filtfilt(b,a,depth_surface_wave));
    scale_depth=0*filt_depth_surface_wave;low_scale=scale_depth; 
    
    for n=1:N
        % threshold 
        dist=abs(sum(mask(:,:,n),2)-filt_depth_surface_wave(n));
        scale_depth(n)        = max(find(dist==min(dist),1,'last'),...
                                    find(Scales{n}>30,1,'first'));
        low_scale(n)          = find(sum(mask(:,:,n),2)>1,1,'last');
%         test(n)= Scales{1}(find(dist==min(dist),1,'last'));
%         test1(n)= Scales{1}(find(sum(mask(:,:,n),2)>1,1,'last'));
    end
    filt_scale_depth = ceil(filtfilt(b,a,scale_depth));
    filt_low_scale   = floor(filtfilt(b,a,low_scale));
%     filt_test = ceil(filtfilt(b,a,test));
%     filt_test1   = floor(filtfilt(b,a,test1));

    Block_filtcwt=struct([]);
    for n=1:N 
        scale2filt =filt_scale_depth(n)+0*Pgrid;
        scale2filt(1:filt_depth_surface_wave(n)) =...
              filt_low_scale(n)+...
              (0:filt_depth_surface_wave(n)-1)*(filt_scale_depth(n)-filt_low_scale(n))/...
              (filt_depth_surface_wave(n)-1);
        %
        mask1=squeeze(mask(:,:,n))*0+1;
        mask1(repmat((1:Smax).',[1 Lmax])<repmat(scale2filt,[Smax,1]))=0;
        %mask1(squeeze(mask(:,:,n))==1)=0;
              
        tempo=Block_signal(:,:,n).*mask1;
        % interp back on the "original" grid (some differences can appear if
        % the original Pressure vector is not monotonic )
        tempo=interp1(Pgrid,tempo.',P_temp{n}).';
        Block_filtcwt{n}=tempo(:,end:-1:1);
    end
end



