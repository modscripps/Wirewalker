function MET = loadShipMET(timeStart,timeEnd)
% load MET data for the period of time specified
% TIMEWIN = time window in days
% TIMENOW = time at the end of

% METDataDir = 'MET';
METDataDir = '/Volumes/current_cruise/met/data';

dateStart = floor(timeStart);
dateEnd = floor(timeEnd);

fileDates = dateStart:dateEnd;
% fileDatesStr = cell(size(fileDates));

% only acquire MET data with existing files
fileDatesStr = {};
for i = 1:numel(fileDates)
    filename = [METDataDir '/' datestr(fileDates(i),'yymmdd') '.MET'];
    if exist(filename,'file')
        fileDatesStr = [fileDatesStr, {filename}];
    end
end

MET = SN_readShipMET(fileDatesStr);

ind = MET.Time >= timeStart & MET.Time <= timeEnd;
METFields = fieldnames(MET);
for i = 1:numel(METFields)
    if ~strcmpi(METFields{i},'readme')
        MET.(METFields{i}) = MET.(METFields{i})(ind,:);
    end
end

return;

end