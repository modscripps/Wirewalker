function [up,down,dataup] = get_upcast(data)
%function [up,down] = get_upcastRBR(data)


% rename variable to make it easy
pdata=data.P;
tdata=data.time;

% buid a filter 
dt=median(diff(tdata)); % sampling period
T=tdata(end)-tdata(1);  % length of the record
disp('check if time series is shorter than 3 hours')
if T<3/24  
    warning('time serie is less than 3 hours, very short for data processing, watch out the results')
end

disp('smooth the pressure to define up and down cast')
Nb  = 3; % filter order
fnb = 1/(2*dt); % Nyquist frequency
fc  = 1/100/dt; % 100 dt (give "large scale patern") 
[b,a]= butter(Nb,fc/fnb,'low');
filt_pdata=filtfilt(b,a,pdata);
dfilt_pdata=diff(filt_pdata);
dfilt_pdata=[dfilt_pdata;dfilt_pdata(end)];
fslope=0*pdata;fslope(dfilt_pdata<0)=0;fslope(dfilt_pdata>0)=1;
ind_peak=find(abs(diff(fslope))==1);
fprintf('identify %i profil \n',round(length(ind_peak)/2))

slope=nan*pdata;
for i=2:length(ind_peak)
    [~,mI]=min(pdata(ind_peak(i-1):ind_peak(i)));
    [~,MI]=max(pdata(ind_peak(i-1):ind_peak(i)));
    if MI>mI
        slope(ind_peak(i-1)+mI:ind_peak(i-1)+MI)=0;%downcast
    else
        slope(ind_peak(i-1)+MI-1:ind_peak(i-1)+mI-1)=1;%upcast
    end
end
down = find(slope==0);
up = find(slope==1);


% Plot it
figure(1);clf;
plot(tdata(down),pdata(down),'.')
hold on
plot(tdata(up),pdata(up),'r.')
set(gca,'ydir','reverse')
title('Verify rising/falling data separation');

%[tempgrid,fluorgrid,salgrid,uppres,uptimes] = placeingrid4(data,slopepos,2);
%title('8m 1st week fluorescence data .25m x 2 min averages in volts');
% [dndatagrid,dnpres,dntimes] = placeingrid2(data,slopeneg,3);
% title('Data from falling half cycles');

if nargout==3
    fields=fieldnames(data);
    for f=1:length(fields)
        wh_field=fields{f};
        dataup.(wh_field)=data.(wh_field)(up,1);
    end

end

end

%     if data(index1,1)<1.0
%         if sum(diff(data(index1-half:index1+half,3)))/(filterlen) < -0.01
%             slope(index1) = 1;
%         end
%     elseif data(index1,1)>21
%         if sum(diff(data(index1-half:index1+half,3)))/(filterlen) < -0.01
%             slope(index1) = 1;
%         end
