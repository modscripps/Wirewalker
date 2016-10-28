tic
set(0,'defaulttextinterpreter','Tex');
timewin = 16/24; % window of time in unit day (default 0.5/24 --> 1/2 hour before)
%timenow = NOW();
timenow=datenum(clock);
minGPSQual = 3;
timebegin = timenow - timewin; 
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
keyboard
getAllPacGyreGPS(timewin*1.2,timenow);
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
fprintf('%s: Done loading files\n' ,datestr(now));

fprintf('%s: Plotting\n' ,datestr(now));
set(0,'defaulttextinterpreter',         'TeX');
buoy_cur_lat = NaN(1, numel(PacificGyreGPS));
buoy_cur_lon = NaN(1, numel(PacificGyreGPS));
buoy_time = NaN(1, numel(PacificGyreGPS));
buoy_goodGPS = false(1,numel(PacificGyreGPS));

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
set(gcf,'Position',get(0,'ScreenSize'));
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

scale_fact = nanmin([(maxlat - minlat) (maxlon - minlon)])*5;

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
    if ~buoy_goodGPS(i)
        buoy_alert_str = '#######';
    end
    eval_str = sprintf('%s, ''Buoy %s%s (%s) [Updated @ %s UTC]''',eval_str,buoy_name{i},buoy_alert_str,buoy_loc,datestr(buoy_time(i),'HH:MM dd-mmm-yy'));
end
eval_str =strcat(eval_str,',''Location'',''SouthOutside'');');
if buoy_count>0
    eval(eval_str);
    set(h_legend,'Location','SouthOutside','color','w','box','on');
end
h_ti = title(sprintf('GPS tracks of WW buoys in last %s hour(s) [as of %s]\n\n', num2str(timewin*24),datestr(now,'HH:MM dd-mmm-yyyy')),'Fontsize',24,'FontWeight','Bold');
hold off;
fprintf('%s: Done plotting\n' ,datestr(now));
SN_printfig('~/Sites/images/BuoyTracks.jpg');
% SN_printfig('images/BuoyTracks.jpg');
toc