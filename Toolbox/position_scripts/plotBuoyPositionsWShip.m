tic
set(0,'defaulttextinterpreter','Tex');
timewin = 24/24; % window of time in unit day (default 0.5/24 --> 1/2 hour before)
%timenow = NOW();
timenow=datenum(clock);
minGPSQual = 3;

%DeployStart=datenum([2014 01 30 09 00 00]);

%DeployStart=datenum([2014 06 21 19 00 00]);
if exist('DeployStart','var')==0
    timebegin = timenow - timewin; 
else
    timebegin = DeployStart;
end

maxlat = NaN;
minlat = NaN;
maxlon = NaN;
minlon = NaN;
xmargin = 0.01;
ymargin = 0.01;
line_color = {[1 0 0],[0 0 1], [1 0 1],[0 1 0], [0 .8 .8], [0.5 0.5 0.1], [0.1 0.5 0.5], [0.5 0.0 0.5], [0.6 0.6 0.6],[0 0 0],[0.5 0.7 0.5]};
markers = {'p','o','^','h','*','s','d','v','^','<','>','.'};
buoy_count = 0;
buoy_name = {'','','','','','','','','','','',''};

fprintf('###############################################\n');
fprintf('###############################################\n');

fprintf('%s: Running plotBuoyPosition.m\n' ,datestr(now));
fprintf('%s: Running getAllPacGyreGPS.m\n' ,datestr(now));
getAllPacGyreGPS(timewin*1.2,timenow,timebegin);
fprintf('%s: Done getAllPacGyreGPS.m\n' ,datestr(now));
fprintf('%s: Loading files\n' ,datestr(now));

try
    load('BuoyData/PacificGyreGPS.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading PacificGyreGPS.mat');
end

try
    load('BuoyData/PacificGyreInstruments.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading PacificGyreInstruments.mat');
end

try
    MET = loadShipMET(timebegin,timenow);
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading MET data with ship position');
end
fprintf('%s: Done loading files\n' ,datestr(now));

buoy_cur_lat = NaN(1, numel(PacificGyreGPS));
buoy_cur_lon = NaN(1, numel(PacificGyreGPS));
buoy_time = NaN(1, numel(PacificGyreGPS));
buoy_goodGPS = false(1,numel(PacificGyreGPS));

fprintf('%s: Plotting\n' ,datestr(now));
set(0,'defaulttextinterpreter',         'TeX');

[t,ind] = nanmax(MET.Time);
%ind = find(ind);
ship.Latitude = MET.LA((ind));
ship.Longitude = MET.LO((ind));
ship.Heading = MET.GY((ind));

for i = 1:numel(PacificGyreGPS)
    if ~isempty(PacificGyreGPS(i).GPSLatitude)
        t_range = PacificGyreGPS(i).DataDateTime < timenow & PacificGyreGPS(i).DataDateTime > timebegin;
        gpsQual = PacificGyreGPS(i).gpsQuality>=minGPSQual;
        maxlat = nanmax([nanmedfilt1(PacificGyreGPS(i).GPSLatitude(t_range&gpsQual),5); maxlat]);
        minlat = nanmin([nanmedfilt1(PacificGyreGPS(i).GPSLatitude(t_range&gpsQual),5); minlat]);
        maxlon = nanmax([nanmedfilt1(PacificGyreGPS(i).GPSLongitude(t_range&gpsQual),5); maxlon]);
        minlon = nanmin([nanmedfilt1(PacificGyreGPS(i).GPSLongitude(t_range&gpsQual),5); minlon]);
    end
end

maxlat = nanmax([ship.Latitude; maxlat]);
minlat = nanmin([ship.Latitude; minlat]);
maxlon = nanmax([ship.Longitude; maxlon]);
minlon = nanmin([ship.Longitude; minlon]);

if isnan(minlon)
    minlon = 0;
end

if isnan(maxlon)
    maxlon = 0;
end

if isnan(minlat)
    minlat = 0;
end

if isnan(maxlat)
    maxlat = 0;
end


figure(2013);
%set(gcf,'Position',get(0,'ScreenSize')/1.75);
set(gcf,'Position',[250 250 1000 1000])
clf


m_proj('UTM','long',[minlon-xmargin maxlon+xmargin],'lat',[minlat-ymargin maxlat+ymargin]);

m_grid('box','fancy','tickdir','in','XaxisLocation','top');
hold on;
for i = 1:numel(PacificGyreGPS)
            t_range = find(PacificGyreGPS(i).DataDateTime < timenow & PacificGyreGPS(i).DataDateTime > timebegin); 
            if isempty(t_range) 
                continue;
            end
            gpsQual = find(PacificGyreGPS(i).gpsQuality>=minGPSQual);
            % check if the current position of the Bouy is good or not....
            if ~isempty(gpsQual)
                if ismember(t_range(1),gpsQual)
                    buoy_goodGPS(i) = true;
                end
            end
            
            buoy_count = buoy_count + 1;
            buoy_name{buoy_count} = PacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = PacificGyreGPS(i).GPSLatitude(t_range(1));
            buoy_cur_lon(buoy_count) = PacificGyreGPS(i).GPSLongitude(t_range(1));
            buoy_time(buoy_count) = PacificGyreGPS(i).DataDateTime(t_range(1));
            
            t_range = PacificGyreGPS(i).DataDateTime < timenow & PacificGyreGPS(i).DataDateTime > timebegin;
            gpsQual = PacificGyreGPS(i).gpsQuality>=minGPSQual;
            
            m_plot(PacificGyreGPS(i).GPSLongitude(t_range&gpsQual),PacificGyreGPS(i).GPSLatitude(t_range&gpsQual),...
                'Color',line_color{buoy_count},'Marker',markers{buoy_count},'MarkerSize',6,'MarkerFaceColor',line_color{buoy_count});
end

scale_fact = nanmin([(maxlat - minlat) (maxlon - minlon)])*2;
%m_gshhs_i('color','k');

h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
    cos((90-ship.Heading)*pi/180)*scale_fact, sin((90-ship.Heading)*pi/180)*scale_fact,...
    'headlength',20,'shaftwidth',15,'key','',...
    'headwidth',10, 'centered','yes','linewidth',2,'facecolor',[0 0 0.8],...
    'linestyle','-');

m_plot(ship.Longitude,ship.Latitude,...
                'Color','w','Marker','+','MarkerSize',20,'MarkerFaceColor','w');

set(gca,'LooseInset',get(gca,'TightInset')*2.4);


eval_str = 'h_legend = legend([h(1:buoy_count)]';
h = NaN(size(buoy_count));
for i = 1:buoy_count
    h(i) = m_plot(buoy_cur_lon(i),buoy_cur_lat(i),...
                'Color',line_color{i},'Marker',markers{i},'MarkerSize',20,'MarkerFaceColor',line_color{i});
    if buoy_cur_lat(i) > 0
        buoy_loc = sprintf('%03d\\circ%02.04f'''' N',floor(buoy_cur_lat(i)),mod(buoy_cur_lat(i)*60,60));
    else
        buoy_loc = sprintf('%03d\\circ%02.04f'''' S',floor(-buoy_cur_lat(i)),mod(-buoy_cur_lat(i)*60,60));
    end
    
    if buoy_cur_lon(i) > 0
        buoy_loc = sprintf('%s, %03d\\circ%02.04f'''' E',buoy_loc, floor(buoy_cur_lon(i)),mod(buoy_cur_lon(i)*60,60));
    else
        buoy_loc = sprintf('%s, %03d\\circ%02.04f'''' W',buoy_loc, floor(-buoy_cur_lon(i)),mod(-buoy_cur_lon(i)*60,60));
    end
    buoy_alert_str = '';
%     if ~buoy_goodGPS(i)
%         buoy_alert_str = '#######';
%     end
    eval_str = sprintf('%s, ''Buoy %s%s (%s) [Updated @ %s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd-mmm-yy'));
end
eval_str =strcat(eval_str,',''Location'',''SouthOutside'');');
%{
try
    load('/Volumes/scienceparty_share/WW_positions/gps_iop.mat')
catch err
      fprintf(1,'%s: unable to load gps_iop',datestr(now));
    disp(err)
end
%}
% if exist('gps_iop','var')==1
%     iop_str = sprintf('%s %s%s %s  %s%s %s [Updated @ %s UTC]','WW GHOST FACE KILLAH',num2str(floor(gps_iop.lat(end))),'N',num2str(mod(gps_iop.lat(end)*60,60)),num2str(floor(gps_iop.lon(end))),'E',num2str(mod(gps_iop.lon(end)*60,60)),datestr(gps_iop.time(end),'HH:MM dd-mmm-yyyy'));
%     annotation('textbox',[0.2 0.2 0.65 0.05],'string' ,iop_str,'fontsize',16)
% end
if buoy_count>0
    eval(eval_str);
    set(h_legend,'Location','SouthOutside','color','w','box','on','fontsize',14);
end
h_ti = title(sprintf('GPS tracks of WW buoys in last %s hour(s) [as of %s]\n\n', num2str((now-timebegin)*24),datestr(now,'HH:MM dd-mmm-yyyy')),'Fontsize',24,'FontWeight','Bold');
hold off;
fprintf('%s: Done plotting\n' ,datestr(now));
SN_printfig('~/Sites/images/BuoyTracks.jpg');
% SN_printfig('images/BuoyTracks.jpg');
toc