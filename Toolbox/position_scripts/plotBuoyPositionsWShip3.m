% this plots both Pacific Gyre and RBR trackers
%
tic
set(0,'defaulttextinterpreter','Tex');
timewin = 48/24; % window of time in unit day (default 0.5/24 --> 1/2 hour before)
%timenow = NOW();
timenow=now;
minGPSQual = 3;

%DeployStart=datenum([2014 01 30 09 00 00]);

%DeployStart=datenum([2014 06 21 19 00 00]);
%{
if exist('DeployStart','var')==0
    timebegin = timenow - timewin; 
else
    timebegin = DeployStart;
    end
%}

timebegin = timenow - timewin; 

maxlat = NaN;
minlat = NaN;
maxlon = NaN;
minlon = NaN;
xmargin = 0.1;
ymargin = 0.1;
line_color = {[1 0 0],[0 0 1], [1 0 1],[0 1 0], [0 .8 .8], [0.5 0.5 0.1], [0.1 0.5 0.5], [0.5 0.0 0.5], [0.6 0.6 0.6],[0 0 0],[0.5 0.7 0.5]};
markers = {'p','o','^','h','*','s','d','v','^','<','>','.'};
buoy_count = 0;
buoy_name = {'','','','','','','','','','','',''};

fprintf('###############################################\n');
fprintf('###############################################\n');

fprintf('%s: Running plotBuoyPosition.m\n' ,datestr(now));
%
fprintf('%s: Running getAllPacGyreGPS.m\n' ,datestr(now));
getAllPacGyreGPS(timewin*1.2,timenow,timebegin);
fprintf('%s: Done getAllPacGyreGPS.m\n' ,datestr(now));

fprintf('%s: Running getAllEmilyPacGyreGPS.m\n' ,datestr(now));
getAllEmilyPacGyreGPS(timewin*1.2,timenow,timebegin);
fprintf('%s: Done getAllEmilyPacGyreGPS.m\n' ,datestr(now));

% fprintf('%s: Running getAllRBR_GPS.m\n' ,datestr(now));
% getAllRBR_GPS(timewin*1.2,timenow,timebegin);
% fprintf('%s: Done getAllRBR_GPS.m\n' ,datestr(now));
fprintf('%s: Running getSoloGPS.m\n' ,datestr(now));
try
getSoloGPS(timewin*1.2,timenow,timebegin);
catch err
    disp('Error in getSoloGPS');
    disp(err);
end
fprintf('%s: Done getSoloGPS.m\n' ,datestr(now));
fprintf('%s: Running getDrifterGPS.m\n' ,datestr(now));
try
getDrifterGPS(timewin*1.2,timenow,timebegin);
catch err
    disp('Error in getDrifterGPS');
    disp(err);
end
fprintf('%s: Done getDrifterGPS.m\n' ,datestr(now));

fprintf('%s: Running getSparBuoyGPS.m\n' ,datestr(now));
try
getSparBuoyGPS(timewin*1.2,timenow,timebegin);
catch err
    disp('Error in getSparBuoyGPS');
    disp(err);
end
fprintf('%s: Done getSparBuoyGPS.m\n' ,datestr(now));

%
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
    load('BuoyData/EmilyPacificGyreGPS.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading EmilyPacificGyreGPS.mat');
end

try
    load('BuoyData/EmilyPacificGyreInstruments.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading EmilyPacificGyreInstruments.mat');
end

try
    load('BuoyData/Drifter_GPS.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading Drifter_GPS.mat');
end

try
    load('BuoyData/Drifter_GPS_Instruments.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading Drifter_GPS_Instruments.mat');
end

try
    load('BuoyData/SparBuoy_GPS.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading SparBuoy_GPS.mat');
end

try
    load('BuoyData/SparBuoy_GPS_Instruments.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading SparBuoy_GPS_Instruments.mat');
end

%{
try
    load('BuoyData/RBR_GPS.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading RBR_GPS.mat');
end

try
    load('BuoyData/RBR_GPS_Instruments.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading RBR_GPS_Instruments.mat');
end
%}
RBR_GPS = [];
RBR_GPS_Instruments = []';

try
    load('BuoyData/SoloFloats_GPS.mat');
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading SoloFloats_GPS.mat');
end

try
    MET = loadShipMET(timebegin,timenow);
catch err
    disp(datestr(now));
    disp(err);
    disp('Problem loading MET data with ship position');
end

fprintf('%s: Done loading files\n' ,datestr(now));
%}
%%
buoy_cur_lat = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_cur_lon = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_time = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
isFloat = false(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_color = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_marker = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_count = 0;

fprintf('%s: Plotting\n' ,datestr(now));
set(0,'defaulttextinterpreter','TeX');

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

for i = 1:numel(SparBuoy_GPS)
    if ~isempty(SparBuoy_GPS(i).Latitude)
        t_range = SparBuoy_GPS(i).DateTime < timenow & SparBuoy_GPS(i).DateTime > timebegin;
        maxlat = nanmax([nanmedfilt1(SparBuoy_GPS(i).Latitude(t_range),5) maxlat]);
        minlat = nanmin([nanmedfilt1(SparBuoy_GPS(i).Latitude(t_range),5) minlat]);
        maxlon = nanmax([nanmedfilt1(SparBuoy_GPS(i).Longitude(t_range),5) maxlon]);
        minlon = nanmin([nanmedfilt1(SparBuoy_GPS(i).Longitude(t_range),5) minlon]);
    end
end


for i = 1:numel(EmilyPacificGyreGPS)
    if ~isempty(EmilyPacificGyreGPS(i).GPSLatitude)
        t_range = EmilyPacificGyreGPS(i).DataDateTime < timenow & EmilyPacificGyreGPS(i).DataDateTime > timebegin;
        gpsQual = EmilyPacificGyreGPS(i).gpsQuality>=minGPSQual;
        maxlat = nanmax([nanmedfilt1(EmilyPacificGyreGPS(i).GPSLatitude(t_range&gpsQual),5); maxlat]);
        minlat = nanmin([nanmedfilt1(EmilyPacificGyreGPS(i).GPSLatitude(t_range&gpsQual),5); minlat]);
        maxlon = nanmax([nanmedfilt1(EmilyPacificGyreGPS(i).GPSLongitude(t_range&gpsQual),5); maxlon]);
        minlon = nanmin([nanmedfilt1(EmilyPacificGyreGPS(i).GPSLongitude(t_range&gpsQual),5); minlon]);
    end
end

for i = 1:numel(RBR_GPS)
    if ~isempty(RBR_GPS(i).Latitude)
        t_range = RBR_GPS(i).DateTime < timenow & RBR_GPS(i).DateTime > timebegin;
        maxlat = nanmax([nanmedfilt1(RBR_GPS(i).Latitude(t_range),5); maxlat]);
        minlat = nanmin([nanmedfilt1(RBR_GPS(i).Latitude(t_range),5); minlat]);
        maxlon = nanmax([nanmedfilt1(RBR_GPS(i).Longitude(t_range),5); maxlon]);
        minlon = nanmin([nanmedfilt1(RBR_GPS(i).Longitude(t_range),5); minlon]);
    end
end

% solo floats
for i = 1:numel(SoloFloats_GPS)
    if ~isempty(SoloFloats_GPS(i).Latitude)
        t_range = SoloFloats_GPS(i).DateTime < timenow & SoloFloats_GPS(i).DateTime > timebegin;
        maxlat = nanmax([nanmedfilt1(SoloFloats_GPS(i).Latitude(t_range),5); maxlat]);
        minlat = nanmin([nanmedfilt1(SoloFloats_GPS(i).Latitude(t_range),5); minlat]);
        maxlon = nanmax([nanmedfilt1(SoloFloats_GPS(i).Longitude(t_range),5); maxlon]);
        minlon = nanmin([nanmedfilt1(SoloFloats_GPS(i).Longitude(t_range),5); minlon]);
    end
end

for i = 1:numel(Drifter_GPS)
    if ~isempty(Drifter_GPS(i).Latitude)
        t_range = Drifter_GPS(i).DateTime < timenow & Drifter_GPS(i).DateTime > timebegin;
        maxlat = nanmax([nanmedfilt1(Drifter_GPS(i).Latitude(t_range),5)'; maxlat]);
        minlat = nanmin([nanmedfilt1(Drifter_GPS(i).Latitude(t_range),5)'; minlat]);
        maxlon = nanmax([nanmedfilt1(Drifter_GPS(i).Longitude(t_range),5)'; maxlon]);
        minlon = nanmin([nanmedfilt1(Drifter_GPS(i).Longitude(t_range),5)'; minlon]);
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
set(gcf,'Position',[250 250 1600 1000])
clf


m_proj('UTM','long',[minlon-xmargin maxlon+xmargin],'lat',[minlat-ymargin maxlat+ymargin]);

m_grid('box','fancy','tickdir','in','XaxisLocation','top');
hold on;

h = [];

for i = 1:numel(PacificGyreGPS)
            t_range = find(PacificGyreGPS(i).DataDateTime < timenow & PacificGyreGPS(i).DataDateTime > timebegin & PacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end            
            
            buoy_count = buoy_count + 1;
            
            lon = PacificGyreGPS(i).GPSLongitude(t_range);
            lat = PacificGyreGPS(i).GPSLatitude(t_range);
            time = PacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            buoy_name{buoy_count} = PacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 's';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','s','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(SparBuoy_GPS)
    t_range = find(SparBuoy_GPS(i).DateTime < timenow & SparBuoy_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    
    isFloat(buoy_count) = false;
    
    lon = SparBuoy_GPS(i).Longitude(t_range);
    lat = SparBuoy_GPS(i).Latitude(t_range);
    time = SparBuoy_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    buoy_name{buoy_count} = SparBuoy_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = '*';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','*','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(EmilyPacificGyreGPS)
            t_range = find(EmilyPacificGyreGPS(i).DataDateTime < timenow &...
                EmilyPacificGyreGPS(i).DataDateTime > timebegin &...
                EmilyPacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end            
            
            buoy_count = buoy_count + 1;
            
            lon = EmilyPacificGyreGPS(i).GPSLongitude(t_range);
            lat = EmilyPacificGyreGPS(i).GPSLatitude(t_range);
            time = EmilyPacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            buoy_name{buoy_count} = EmilyPacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 'd';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(RBR_GPS)
            t_range = find(RBR_GPS(i).DateTime < timenow & RBR_GPS(i).DateTime > timebegin); 
            if isempty(t_range) 
                continue;
            end           
            
            
            buoy_count = buoy_count + 1;
            
            lon = RBR_GPS(i).Longitude(t_range);
            lat = RBR_GPS(i).Latitude(t_range);
            time = RBR_GPS(i).DateTime(t_range);
            [max_time, I] = max(time);
            
            buoy_name{buoy_count} = RBR_GPS_Instruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
                        
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 'd';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(SoloFloats_GPS)
            t_range = find(SoloFloats_GPS(i).DateTime < timenow & SoloFloats_GPS(i).DateTime > timebegin); 
            if isempty(t_range) 
                continue;
            end   
            
            buoy_count = buoy_count + 1;
            
            
            isFloat(buoy_count) = true;
            
            lon = SoloFloats_GPS(i).Longitude(t_range);
            lat = SoloFloats_GPS(i).Latitude(t_range);
            time = SoloFloats_GPS(i).DateTime(t_range);
            [max_time, I] = max(time);
            
            buoy_name{buoy_count} = SoloFloats_GPS(i).DeviceID{1};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
                        
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = '^';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','^','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(Drifter_GPS)
    t_range = find(Drifter_GPS(i).DateTime < timenow & Drifter_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    
    isFloat(buoy_count) = false;
    
    lon = Drifter_GPS(i).Longitude(t_range);
    lat = Drifter_GPS(i).Latitude(t_range);
    time = Drifter_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    buoy_name{buoy_count} = Drifter_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = 'p';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','p','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

scale_fact = nanmin([(maxlat - minlat) (maxlon - minlon)])*2;
%m_gshhs_i('color','k');

% h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
%     cos((90-ship.Heading)*pi/180)*scale_fact, sin((90-ship.Heading)*pi/180)*scale_fact,...
%     'headlength',20,'shaftwidth',15,'key','',...
%     'headwidth',10, 'centered','yes','linewidth',2,'facecolor',[0.2 0.2 0.8],...
%     'linestyle','-');

ship_scale = 0.5;

h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
    cos((90-ship.Heading)*pi/180)*scale_fact*ship_scale, sin((90-ship.Heading)*pi/180)*scale_fact*ship_scale,...
    'headlength',20*ship_scale,'shaftwidth',15*ship_scale,'key','',...
    'headwidth',10*ship_scale, 'centered','yes','linewidth',2*ship_scale,'facecolor',[0.2 0.2 0.8],...
    'linestyle','-');

m_plot(ship.Longitude,ship.Latitude,...
                'Color','w','Marker','+','MarkerSize',20,'MarkerFaceColor','w');

set(gca,'LooseInset',get(gca,'TightInset')*2.4);


eval_str = 'h_legend = legend([h(1:buoy_count)]';
i_buoy = 0;
for i = 1:buoy_count
    
    i_buoy = i_buoy + 1;
    h(i) = m_plot(buoy_cur_lon(i),buoy_cur_lat(i),...
                'Color',buoy_color{i},'Marker',buoy_marker{i},'MarkerSize',20,...
                'MarkerFaceColor',buoy_color{i});
    if buoy_cur_lat(i) > 0
        buoy_loc = sprintf('%03d\\circ%02.02f'''' N',floor(buoy_cur_lat(i)),mod(buoy_cur_lat(i)*60,60));
    else
        buoy_loc = sprintf('%03d\\circ%02.02f'''' S',floor(-buoy_cur_lat(i)),mod(-buoy_cur_lat(i)*60,60));
    end
    
    if buoy_cur_lon(i) > 0
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' E',buoy_loc, floor(buoy_cur_lon(i)),mod(buoy_cur_lon(i)*60,60));
    else
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' W',buoy_loc, floor(-buoy_cur_lon(i)),mod(-buoy_cur_lon(i)*60,60));
    end
    buoy_alert_str = '';
%     if ~buoy_goodGPS(i)
%         buoy_alert_str = '#######';
%     end
    if isFloat(i)
        eval_str = sprintf('%s, ''Solo %s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    else
        eval_str = sprintf('%s, ''%s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    end
end
eval_str =strcat(eval_str,',''Location'',''NorthEastOutside'');');
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
    set(h_legend,'Location','NorthEastOutside','color','w','box','on','fontsize',16);
end
h_ti = title(sprintf('GPS tracks of WW buoys in last %2.f hour(s) [as of %s]\n\n', (now-timebegin)*24,datestr(now,'HH:MM dd-mmm-yyyy')),'Fontsize',24,'FontWeight','Bold');
hold off;
fprintf('%s: Done plotting\n' ,datestr(now));
SN_printfig('~/Sites/images/BuoyTracks.jpg');
SN_printfig('images/BuoyTracks.jpg');
toc

%%
xmargin = 2/60;
ymargin = 2/60;

buoy_cur_lat = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_cur_lon = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_time = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
isFloat = false(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_color = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_marker = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_count = 0;

fprintf('%s: Plotting\n' ,datestr(now));
set(0,'defaulttextinterpreter',         'TeX');

[t,ind] = nanmax(MET.Time);
%ind = find(ind);
ship.Latitude = MET.LA((ind));
ship.Longitude = MET.LO((ind));
ship.Heading = MET.GY((ind));

minlat = ship.Latitude-ymargin;
maxlat = ship.Latitude+ymargin;
minlon = ship.Longitude-xmargin;
maxlon = ship.Longitude+xmargin;

figure(2015);
%set(gcf,'Position',get(0,'ScreenSize')/1.75);
set(gcf,'Position',[250 250 1600 1000])
clf


m_proj('UTM','long',[minlon maxlon],'lat',[minlat maxlat]);

m_grid('box','fancy','tickdir','in','XaxisLocation','top');
hold on;

h = [];
for i = 1:numel(PacificGyreGPS)
            t_range = find(PacificGyreGPS(i).DataDateTime < timenow & PacificGyreGPS(i).DataDateTime > timebegin & PacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end
            
            lon = PacificGyreGPS(i).GPSLongitude(t_range);
            lat = PacificGyreGPS(i).GPSLatitude(t_range);
            
            time = PacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
                continue;
            end
            
            buoy_count = buoy_count + 1;
            buoy_name{buoy_count} = PacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 's';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','s','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(SparBuoy_GPS)
    t_range = find(SparBuoy_GPS(i).DateTime < timenow & SparBuoy_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    lon = SparBuoy_GPS(i).Longitude(t_range);
    lat = SparBuoy_GPS(i).Latitude(t_range);
    time = SparBuoy_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    buoy_name{buoy_count} = SparBuoy_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = '*';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','*','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(EmilyPacificGyreGPS)
            t_range = find(EmilyPacificGyreGPS(i).DataDateTime < timenow &...
                EmilyPacificGyreGPS(i).DataDateTime > timebegin &...
                EmilyPacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end
            
            lon = EmilyPacificGyreGPS(i).GPSLongitude(t_range);
            lat = EmilyPacificGyreGPS(i).GPSLatitude(t_range);
            
            time = EmilyPacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
                continue;
            end
            
            buoy_count = buoy_count + 1;
            buoy_name{buoy_count} = EmilyPacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 'd';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(RBR_GPS)
    t_range = find(RBR_GPS(i).DateTime < timenow & RBR_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    
    
    
    lon = RBR_GPS(i).Longitude(t_range);
    lat = RBR_GPS(i).Latitude(t_range);
    time = RBR_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    buoy_name{buoy_count} = RBR_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = 'd';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(SoloFloats_GPS)
    t_range = find(SoloFloats_GPS(i).DateTime < timenow & SoloFloats_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    
    
    lon = SoloFloats_GPS(i).Longitude(t_range);
    lat = SoloFloats_GPS(i).Latitude(t_range);
    time = SoloFloats_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    buoy_count = buoy_count + 1;
    isFloat(buoy_count) = true;
    buoy_name{buoy_count} = SoloFloats_GPS(i).DeviceID{1};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = '^';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','^','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(Drifter_GPS)
    t_range = find(Drifter_GPS(i).DateTime < timenow & Drifter_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    lon = Drifter_GPS(i).Longitude(t_range);
    lat = Drifter_GPS(i).Latitude(t_range);
    time = Drifter_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    buoy_name{buoy_count} = Drifter_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = 'p';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','p','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

scale_fact = nanmin([(maxlat - minlat) (maxlon - minlon)])*2;
%m_gshhs_i('color','k');

% h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
%     cos((90-ship.Heading)*pi/180)*scale_fact, sin((90-ship.Heading)*pi/180)*scale_fact,...
%     'headlength',20,'shaftwidth',15,'key','',...
%     'headwidth',10, 'centered','yes','linewidth',2,'facecolor',[0.2 0.2 0.8],...
%     'linestyle','-');

ship_scale = 0.5;

h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
    cos((90-ship.Heading)*pi/180)*scale_fact*ship_scale, sin((90-ship.Heading)*pi/180)*scale_fact*ship_scale,...
    'headlength',20*ship_scale,'shaftwidth',15*ship_scale,'key','',...
    'headwidth',10*ship_scale, 'centered','yes','linewidth',2*ship_scale,'facecolor',[0.2 0.2 0.8],...
    'linestyle','-');

m_plot(ship.Longitude,ship.Latitude,...
                'Color','w','Marker','+','MarkerSize',20,'MarkerFaceColor','w');

set(gca,'LooseInset',get(gca,'TightInset')*2.4);


eval_str = 'h_legend = legend([h(1:buoy_count)]';
i_buoy = 0;
for i = 1:buoy_count
    
    i_buoy = i_buoy + 1;
    h(i) = m_plot(buoy_cur_lon(i),buoy_cur_lat(i),...
                'Color',buoy_color{i},'Marker',buoy_marker{i},'MarkerSize',20,...
                'MarkerFaceColor',buoy_color{i});
    if buoy_cur_lat(i) > 0
        buoy_loc = sprintf('%03d\\circ%02.02f'''' N',floor(buoy_cur_lat(i)),mod(buoy_cur_lat(i)*60,60));
    else
        buoy_loc = sprintf('%03d\\circ%02.02f'''' S',floor(-buoy_cur_lat(i)),mod(-buoy_cur_lat(i)*60,60));
    end
    
    if buoy_cur_lon(i) > 0
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' E',buoy_loc, floor(buoy_cur_lon(i)),mod(buoy_cur_lon(i)*60,60));
    else
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' W',buoy_loc, floor(-buoy_cur_lon(i)),mod(-buoy_cur_lon(i)*60,60));
    end
    buoy_alert_str = '';
%     if ~buoy_goodGPS(i)
%         buoy_alert_str = '#######';
%     end
    if isFloat(i)
        eval_str = sprintf('%s, ''Solo %s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    else
        eval_str = sprintf('%s, ''%s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    end
end
eval_str =strcat(eval_str,',''Location'',''NorthEastOutside'');');
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
    set(h_legend,'Location','NorthEastOutside','color','w','box','on','fontsize',16);
end
h_ti = title(sprintf('2 nautical miles around ship\nGPS tracks of WW buoys in last %2.f hour(s) [as of %s]\n', (now-timebegin)*24,datestr(now,'HH:MM dd-mmm-yyyy')),'Fontsize',24,'FontWeight','Bold');
hold off;
fprintf('%s: Done plotting\n' ,datestr(now));
SN_printfig('~/Sites/images/BuoyTracks_aroundShip.jpg');
% SN_printfig('images/BuoyTracks.jpg');
toc


%%
xmargin = 5/60;
ymargin = 5/60;

buoy_cur_lat = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_cur_lon = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_time = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
isFloat = false(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_color = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_marker = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_count = 0;

fprintf('%s: Plotting\n' ,datestr(now));
set(0,'defaulttextinterpreter',         'TeX');

[t,ind] = nanmax(MET.Time);
%ind = find(ind);
ship.Latitude = MET.LA((ind));
ship.Longitude = MET.LO((ind));
ship.Heading = MET.GY((ind));

minlat = ship.Latitude-ymargin;
maxlat = ship.Latitude+ymargin;
minlon = ship.Longitude-xmargin;
maxlon = ship.Longitude+xmargin;

figure(2014);
%set(gcf,'Position',get(0,'ScreenSize')/1.75);
set(gcf,'Position',[250 250 1600 1000])
clf


m_proj('UTM','long',[minlon maxlon],'lat',[minlat maxlat]);

m_grid('box','fancy','tickdir','in','XaxisLocation','top');
hold on;

h = [];
for i = 1:numel(PacificGyreGPS)
            t_range = find(PacificGyreGPS(i).DataDateTime < timenow & PacificGyreGPS(i).DataDateTime > timebegin & PacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end
            
            lon = PacificGyreGPS(i).GPSLongitude(t_range);
            lat = PacificGyreGPS(i).GPSLatitude(t_range);
            
            time = PacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
                continue;
            end
            
            buoy_count = buoy_count + 1;
            buoy_name{buoy_count} = PacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 's';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','s','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(SparBuoy_GPS)
    t_range = find(SparBuoy_GPS(i).DateTime < timenow & SparBuoy_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    lon = SparBuoy_GPS(i).Longitude(t_range);
    lat = SparBuoy_GPS(i).Latitude(t_range);
    time = SparBuoy_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    buoy_name{buoy_count} = SparBuoy_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = '*';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','*','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(EmilyPacificGyreGPS)
            t_range = find(EmilyPacificGyreGPS(i).DataDateTime < timenow &...
                EmilyPacificGyreGPS(i).DataDateTime > timebegin &...
                EmilyPacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end
            
            lon = EmilyPacificGyreGPS(i).GPSLongitude(t_range);
            lat = EmilyPacificGyreGPS(i).GPSLatitude(t_range);
            
            time = EmilyPacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
                continue;
            end
            
            buoy_count = buoy_count + 1;
            buoy_name{buoy_count} = EmilyPacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 'd';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(RBR_GPS)
    t_range = find(RBR_GPS(i).DateTime < timenow & RBR_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    
    
    
    lon = RBR_GPS(i).Longitude(t_range);
    lat = RBR_GPS(i).Latitude(t_range);
    time = RBR_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    buoy_name{buoy_count} = RBR_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = 'd';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(SoloFloats_GPS)
    t_range = find(SoloFloats_GPS(i).DateTime < timenow & SoloFloats_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    
    
    lon = SoloFloats_GPS(i).Longitude(t_range);
    lat = SoloFloats_GPS(i).Latitude(t_range);
    time = SoloFloats_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    buoy_count = buoy_count + 1;
    isFloat(buoy_count) = true;
    buoy_name{buoy_count} = SoloFloats_GPS(i).DeviceID{1};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = '^';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','^','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(Drifter_GPS)
    t_range = find(Drifter_GPS(i).DateTime < timenow & Drifter_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    lon = Drifter_GPS(i).Longitude(t_range);
    lat = Drifter_GPS(i).Latitude(t_range);
    time = Drifter_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    buoy_name{buoy_count} = Drifter_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = 'p';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','p','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

scale_fact = nanmin([(maxlat - minlat) (maxlon - minlon)])*2;
%m_gshhs_i('color','k');

% h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
%     cos((90-ship.Heading)*pi/180)*scale_fact, sin((90-ship.Heading)*pi/180)*scale_fact,...
%     'headlength',20,'shaftwidth',15,'key','',...
%     'headwidth',10, 'centered','yes','linewidth',2,'facecolor',[0.2 0.2 0.8],...
%     'linestyle','-');

ship_scale = 0.5;

h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
    cos((90-ship.Heading)*pi/180)*scale_fact*ship_scale, sin((90-ship.Heading)*pi/180)*scale_fact*ship_scale,...
    'headlength',20*ship_scale,'shaftwidth',15*ship_scale,'key','',...
    'headwidth',10*ship_scale, 'centered','yes','linewidth',2*ship_scale,'facecolor',[0.2 0.2 0.8],...
    'linestyle','-');

m_plot(ship.Longitude,ship.Latitude,...
                'Color','w','Marker','+','MarkerSize',20,'MarkerFaceColor','w');

set(gca,'LooseInset',get(gca,'TightInset')*2.4);


eval_str = 'h_legend = legend([h(1:buoy_count)]';
i_buoy = 0;
for i = 1:buoy_count
    
    i_buoy = i_buoy + 1;
    h(i) = m_plot(buoy_cur_lon(i),buoy_cur_lat(i),...
                'Color',buoy_color{i},'Marker',buoy_marker{i},'MarkerSize',20,...
                'MarkerFaceColor',buoy_color{i});
    if buoy_cur_lat(i) > 0
        buoy_loc = sprintf('%03d\\circ%02.02f'''' N',floor(buoy_cur_lat(i)),mod(buoy_cur_lat(i)*60,60));
    else
        buoy_loc = sprintf('%03d\\circ%02.02f'''' S',floor(-buoy_cur_lat(i)),mod(-buoy_cur_lat(i)*60,60));
    end
    
    if buoy_cur_lon(i) > 0
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' E',buoy_loc, floor(buoy_cur_lon(i)),mod(buoy_cur_lon(i)*60,60));
    else
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' W',buoy_loc, floor(-buoy_cur_lon(i)),mod(-buoy_cur_lon(i)*60,60));
    end
    buoy_alert_str = '';
%     if ~buoy_goodGPS(i)
%         buoy_alert_str = '#######';
%     end
    if isFloat(i)
        eval_str = sprintf('%s, ''Solo %s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    else
        eval_str = sprintf('%s, ''%s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    end
end
eval_str =strcat(eval_str,',''Location'',''NorthEastOutside'');');
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
    set(h_legend,'Location','NorthEastOutside','color','w','box','on','fontsize',16);
end
h_ti = title(sprintf('5 nautical miles around ship\nGPS tracks of WW buoys in last %2.f hour(s) [as of %s]\n', (now-timebegin)*24,datestr(now,'HH:MM dd-mmm-yyyy')),'Fontsize',24,'FontWeight','Bold');
hold off;
fprintf('%s: Done plotting\n' ,datestr(now));
SN_printfig('~/Sites/images/BuoyTracks_aroundShip_5nm.jpg');
% SN_printfig('images/BuoyTracks.jpg');

%%
xmargin = 10/60;
ymargin = 10/60;

buoy_cur_lat = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_cur_lon = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_time = NaN(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
isFloat = false(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_color = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_marker = cell(1, numel(PacificGyreGPS)+numel(RBR_GPS)+numel(SoloFloats_GPS)+numel(Drifter_GPS) + numel(SparBuoy_GPS) + numel(EmilyPacificGyreGPS));
buoy_count = 0;

fprintf('%s: Plotting\n' ,datestr(now));
set(0,'defaulttextinterpreter','TeX');

[t,ind] = nanmax(MET.Time);
%ind = find(ind);
ship.Latitude = MET.LA((ind));
ship.Longitude = MET.LO((ind));
ship.Heading = MET.GY((ind));

forward_range = 20/60;

x_lookforward = forward_range*cos((90-ship.Heading)*pi/180);
y_lookforward = forward_range*sin((90-ship.Heading)*pi/180);

minlat = ship.Latitude-ymargin;
maxlat = ship.Latitude+ymargin;
minlon = ship.Longitude-xmargin;
maxlon = ship.Longitude+xmargin;

if y_lookforward < 0
    minlat = minlat + y_lookforward;
else
    maxlat = maxlat + y_lookforward;
end

if x_lookforward < 0
    minlon = minlon + x_lookforward;
else
    maxlon = maxlon + x_lookforward;
end

figure(2014);
%set(gcf,'Position',get(0,'ScreenSize')/1.75);
set(gcf,'Position',[250 250 1600 1000])
clf


m_proj('UTM','long',[minlon maxlon],'lat',[minlat maxlat]);

m_grid('box','fancy','tickdir','in','XaxisLocation','top');
hold on;

h = [];
for i = 1:numel(PacificGyreGPS)
            t_range = find(PacificGyreGPS(i).DataDateTime < timenow & PacificGyreGPS(i).DataDateTime > timebegin & PacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end
            
            lon = PacificGyreGPS(i).GPSLongitude(t_range);
            lat = PacificGyreGPS(i).GPSLatitude(t_range);
            
            time = PacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
                continue;
            end
            
            buoy_count = buoy_count + 1;
            buoy_name{buoy_count} = PacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 's';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','s','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(SparBuoy_GPS)
    t_range = find(SparBuoy_GPS(i).DateTime < timenow & SparBuoy_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    lon = SparBuoy_GPS(i).Longitude(t_range);
    lat = SparBuoy_GPS(i).Latitude(t_range);
    time = SparBuoy_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    buoy_name{buoy_count} = SparBuoy_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = '*';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','*','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(EmilyPacificGyreGPS)
            t_range = find(EmilyPacificGyreGPS(i).DataDateTime < timenow &...
                EmilyPacificGyreGPS(i).DataDateTime > timebegin &...
                EmilyPacificGyreGPS(i).gpsQuality>=minGPSQual); 
            if isempty(t_range) 
                continue;
            end
            
            lon = EmilyPacificGyreGPS(i).GPSLongitude(t_range);
            lat = EmilyPacificGyreGPS(i).GPSLatitude(t_range);
            
            time = EmilyPacificGyreGPS(i).DataDateTime(t_range);
            [max_time, I] = max(time);
            
            if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
                continue;
            end
            
            buoy_count = buoy_count + 1;
            buoy_name{buoy_count} = EmilyPacificGyreInstruments.DeviceName{i};
            buoy_cur_lat(buoy_count) = lat(I);
            buoy_cur_lon(buoy_count) = lon(I);
            buoy_time(buoy_count) = time(I);
            
            buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
            buoy_marker{buoy_count} = 'd';
            
            m_plot(lon,lat,...
                'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
                'MarkerFaceColor',buoy_color{buoy_count});
            
            
end

for i = 1:numel(RBR_GPS)
    t_range = find(RBR_GPS(i).DateTime < timenow & RBR_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    
    
    
    lon = RBR_GPS(i).Longitude(t_range);
    lat = RBR_GPS(i).Latitude(t_range);
    time = RBR_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    buoy_name{buoy_count} = RBR_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = 'd';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','d','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(SoloFloats_GPS)
    t_range = find(SoloFloats_GPS(i).DateTime < timenow & SoloFloats_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    
    
    lon = SoloFloats_GPS(i).Longitude(t_range);
    lat = SoloFloats_GPS(i).Latitude(t_range);
    time = SoloFloats_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    buoy_count = buoy_count + 1;
    isFloat(buoy_count) = true;
    buoy_name{buoy_count} = SoloFloats_GPS(i).DeviceID{1};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = '^';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','^','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

for i = 1:numel(Drifter_GPS)
    t_range = find(Drifter_GPS(i).DateTime < timenow & Drifter_GPS(i).DateTime > timebegin);
    if isempty(t_range)
        continue;
    end
    
    lon = Drifter_GPS(i).Longitude(t_range);
    lat = Drifter_GPS(i).Latitude(t_range);
    time = Drifter_GPS(i).DateTime(t_range);
    [max_time, I] = max(time);
    
    if lat(I)>maxlat || lat(I)<minlat || lon(I) > maxlon || lon(I) < minlon
        continue;
    end
    
    buoy_count = buoy_count + 1;
    
    buoy_name{buoy_count} = Drifter_GPS_Instruments.DeviceName{i};
    buoy_cur_lat(buoy_count) = lat(I);
    buoy_cur_lon(buoy_count) = lon(I);
    buoy_time(buoy_count) = time(I);
    
    buoy_color{buoy_count} = line_color{mod(buoy_count,numel(line_color))+1};
    buoy_marker{buoy_count} = 'p';
    
    m_plot(lon,lat,...
        'Color',buoy_color{buoy_count},'Marker','p','MarkerSize',4,...
        'MarkerFaceColor',buoy_color{buoy_count});
end

scale_fact = nanmin([(maxlat - minlat) (maxlon - minlon)])*2;
%m_gshhs_i('color','k');

% h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
%     cos((90-ship.Heading)*pi/180)*scale_fact, sin((90-ship.Heading)*pi/180)*scale_fact,...
%     'headlength',20,'shaftwidth',15,'key','',...
%     'headwidth',10, 'centered','yes','linewidth',2,'facecolor',[0.2 0.2 0.8],...
%     'linestyle','-');

ship_scale = 0.5;

h_ship = m_vec(scale_fact*1.1, ship.Longitude,ship.Latitude,...
    cos((90-ship.Heading)*pi/180)*scale_fact*ship_scale, sin((90-ship.Heading)*pi/180)*scale_fact*ship_scale,...
    'headlength',20*ship_scale,'shaftwidth',15*ship_scale,'key','',...
    'headwidth',10*ship_scale, 'centered','yes','linewidth',2*ship_scale,'facecolor',[0.2 0.2 0.8],...
    'linestyle','-');

m_plot(ship.Longitude,ship.Latitude,...
                'Color','w','Marker','+','MarkerSize',20,'MarkerFaceColor','w');

set(gca,'LooseInset',get(gca,'TightInset')*2.4);


eval_str = 'h_legend = legend([h(1:buoy_count)]';
i_buoy = 0;
for i = 1:buoy_count
    
    i_buoy = i_buoy + 1;
    h(i) = m_plot(buoy_cur_lon(i),buoy_cur_lat(i),...
                'Color',buoy_color{i},'Marker',buoy_marker{i},'MarkerSize',20,...
                'MarkerFaceColor',buoy_color{i});
    if buoy_cur_lat(i) > 0
        buoy_loc = sprintf('%03d\\circ%02.02f'''' N',floor(buoy_cur_lat(i)),mod(buoy_cur_lat(i)*60,60));
    else
        buoy_loc = sprintf('%03d\\circ%02.02f'''' S',floor(-buoy_cur_lat(i)),mod(-buoy_cur_lat(i)*60,60));
    end
    
    if buoy_cur_lon(i) > 0
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' E',buoy_loc, floor(buoy_cur_lon(i)),mod(buoy_cur_lon(i)*60,60));
    else
        buoy_loc = sprintf('%s, %03d\\circ%02.02f'''' W',buoy_loc, floor(-buoy_cur_lon(i)),mod(-buoy_cur_lon(i)*60,60));
    end
    buoy_alert_str = '';
%     if ~buoy_goodGPS(i)
%         buoy_alert_str = '#######';
%     end
    if isFloat(i)
        eval_str = sprintf('%s, ''Solo %s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    else
        eval_str = sprintf('%s, ''%s%s (%s) [%s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd/mm'));
    end
end
eval_str =strcat(eval_str,',''Location'',''NorthEastOutside'');');
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
    set(h_legend,'Location','NorthEastOutside','color','w','box','on','fontsize',16);
end
h_ti = title(sprintf('10 nautical miles around ship w/ 20 nmi ahead \nGPS tracks of WW buoys in last %2.f hour(s) [as of %s]\n', (now-timebegin)*24,datestr(now,'HH:MM dd-mmm-yyyy')),'Fontsize',24,'FontWeight','Bold');
hold off;
fprintf('%s: Done plotting\n' ,datestr(now));
SN_printfig('~/Sites/images/BuoyTracks_aroundShip_3nm_20nmS.jpg');
% SN_printfig('images/BuoyTracks.jpg');
toc