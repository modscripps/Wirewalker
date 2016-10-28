function [up,down,dataup] = get_upcastRBR_4hz(data)
%function [up,down] = get_upcastRBR(data)


pdata=data.P;
tdata=data.time;

% determine WW direction
filterlen = 4*5;
half = filterlen/2;
slope = zeros(length(pdata),1);
for index1 = half+1:length(pdata)-half
    if sum(diff(pdata(index1-half:index1+half)))/(filterlen) < -0.005
        slope(index1) = 1;
    end
end

%dbounce slope evaluation
minsamples = 60;
filterlen2 = 2*minsamples+1;
for index1 = minsamples+1:length(slope)-minsamples
    slope(index1) = round(sum(slope(index1-minsamples:index1+minsamples))/filterlen2);
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
    dataup.time=data.time(up);
    dataup.P=data.P(up);
    dataup.T=data.T(up);
    if isfield(data,'C')==1
        dataup.C=data.C(up);
    end
    if isfield(data,'v1')==1
        dataup.v1=data.v1(up);
    end
    if isfield(data,'v2')==1
        dataup.v2=data.v2(up);
    end
    if isfield(data,'S')==1
        dataup.S=data.S(up);
    end
    if isfield(data,'SA')==1
        dataup.SA=data.SA(up);
    end
    if isfield(data,'CT')==1
        dataup.CT=data.CT(up);
    end
    if isfield(data,'rho')==1
        dataup.rho=data.rho(up);
    end
    if isfield(data,'dPdt')==1
        dataup.dPdt=data.dPdt(up);
    end
    if isfield(data,'sigma')==1
        dataup.sigma=data.sigma(up);
    end
    if isfield(data,'Tc')==1
        dataup.Tc=data.Tc(up);
    end
    if isfield(data,'Cc')==1
        dataup.Cc=data.Cc(up);
    end
    if isfield(data,'F_chla')==1
        dataup.F_chla=data.F_chla(up);
    end
    if isfield(data,'F_CDOM')==1
        dataup.F_CDOM=data.F_CDOM(up);
    end
    if isfield(data,'O2_volt')==1
        dataup.O2_volt=data.O2_volt(up);
    end
    if isfield(data,'DO')==1
        dataup.DO=data.DO(up);
    end
    if isfield(data,'DO_percent')==1
        dataup.DO_percent=data.DO_percent(up);
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
