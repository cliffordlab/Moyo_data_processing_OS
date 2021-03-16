function dataByDate = organizeDataByDate_Moyo(t, x, y, z, moodSwipe, ...
    moodZoom, kccq, phq, location, call, painSwipe, ...
    promis, qlesq, startHour)

% Check required inputs
if ~isnumeric(t) || ~isnumeric(x) || ...
   ~isnumeric(y) || ~isnumeric(z) || ...
   ~isnumeric(startHour)
    error('Error! Ensure all required inputs are numeric.');
end

% Set default start hour for all dates to midnight
if nargin < 9
    startHour = 0;
end

% Find the earliest and latest timestamps from among ACC 
tStartAllData = min([t; kccq.t; moodZoom.t; phq.t; ...
    location.t; call.t; moodSwipe.t; painSwipe.t; promis.t; qlesq.t]);
tEndAllData = max([t; kccq.t; moodZoom.t; phq.t; ...
    location.t; call.t; moodSwipe.t; painSwipe.t; promis.t; qlesq.t]);

if isempty(tStartAllData) && isempty(tEndAllData); dataByDate = []; return; end

% Convert to Matlab time
tStartAllDataNum = datenum(datestr(tStartAllData, 'dd-mmm-yyyy'));
tEndAllDataNum = datenum(datestr(tEndAllData, 'dd-mmm-yyyy'));

% Offset so the first and last date start on 'startHour
tStartAllDataNum = tStartAllDataNum + hours(startHour);
tEndAllDataNum = tEndAllDataNum + hours(startHour);

% Create arrays of days;
% add +1 so if min and max time are the same day, we produce a day array of length 1
totalDays = 1:days(tEndAllDataNum - tStartAllDataNum + 1);
dayArray = days(tStartAllDataNum + totalDays - 1); % notice the -1 so the first day is tStartAllData

% Initialize all output structure fields as blank
for iDay = 1:length(dayArray)
    dataByDate(iDay).date = [];
    dataByDate(iDay).accTime = [];
    dataByDate(iDay).accX = [];
    dataByDate(iDay).accY = [];
    dataByDate(iDay).accZ = [];
    dataByDate(iDay).MS = [];
    dataByDate(iDay).PS = [];   
    dataByDate(iDay).qlesq = [];        
    dataByDate(iDay).MZ = [];    
    dataByDate(iDay).Promis = [];        
    dataByDate(iDay).KCCQsummary = [];
    dataByDate(iDay).KCCQql = [];
    dataByDate(iDay).KCCQpl = [];
    dataByDate(iDay).KCCQsf = [];
    dataByDate(iDay).KCCQsl = [];
    dataByDate(iDay).PHQ9summary = []; 
    dataByDate(iDay).PHQ9q9 = []; 
    dataByDate(iDay).loc = [];    
    dataByDate(iDay).callID = [];    
    dataByDate(iDay).callType = [];  
    dataByDate(iDay).callDur = [];
    dataByDate(iDay).callTime = [];
end

% Loop through each day in the date range and save ACC and JSON data
% for that day in that element of the structure
for iDay = 1:length(dayArray)

    % Determine start time, i.e. this day
    startDate = dayArray(iDay);
    
    % Append structure field storing all dates
    dataByDate(iDay).date = startDate;
    
    % Set end date to 24 hours after the start of thisDay
    endDate = startDate + 1;
    
    % Save this date to array of dates in readable format
    dates(iDay) = startDate;
    
    % Isolate all ACC data between startDate and endDate
    [tToday, xToday, yToday, zToday] = isolateAccDataInDateRange(t, x, y, z, ...
        startDate, 'endDate', endDate, 'starttime', startHour);
    
    % Keep only unique values
    [tToday, idx, ~] = unique(tToday);
    xToday = xToday(idx);
    yToday = yToday(idx);
    zToday = zToday(idx); 
    
    % Append structure with ACC data in this window
    dataByDate(iDay).accTime = tToday;
    dataByDate(iDay).accX = xToday;
    dataByDate(iDay).accY = yToday;
    dataByDate(iDay).accZ = zToday;

    % Isolate all MS data between startDate and endDate
    moodSwipeToday = isolateMSDataInDateRange(moodSwipe, startDate, ...
        'endDate', endDate, 'starttime', startHour);
    
    if ~isempty(moodSwipeToday.val) 
        [~, idx, ~] = unique(moodSwipeToday.t);
        MSVal = moodSwipeToday.val(idx);
        dataByDate(iDay).MS = MSVal;
    end
    
    % Isolate all PS data between startDate and endDate
    painSwipeToday = isolatePSDataInDateRange(painSwipe, startDate, ...
        'endDate', endDate, 'starttime', startHour);
    
    if ~isempty(painSwipeToday.val) 
        [~, idx, ~] = unique(painSwipeToday.t);
        PSVal = painSwipeToday.val(idx);
        dataByDate(iDay).PS = PSVal;
    end  
    
    % Isolate all qlesq data between startDate and endDate
    qlesqToday = isolateQlesqDataInDateRange(qlesq, startDate, ...
        'endDate', endDate, 'starttime', startHour);
    
    if ~isempty(qlesqToday.val) 
        [~, idx, ~] = unique(qlesqToday.t);
        qlesqVal = qlesqToday.val(idx);
        dataByDate(iDay).qlesq = qlesqVal;
    end     
    
    % Isolate all KCCQ data between startDate and endDate
    kccqToday = isolateKCCQDataInDateRange(kccq, startDate, ...
        'endDate', endDate, 'starttime', startHour);
    
    if ~isempty(kccqToday.summary) 
        dataByDate(iDay).KCCQsummary = kccqToday.summary;
        dataByDate(iDay).KCCQql = kccqToday.ql;
        dataByDate(iDay).KCCQsl = kccqToday.sl;
        dataByDate(iDay).KCCQsf = kccqToday.sf;
        dataByDate(iDay).KCCQpl = kccqToday.pl;
    end
    
    % Isolate all PHQ9 data between startDate and endDate
    phqToday = isolatePHQ9DataInDateRange(phq, startDate, ...
        'endDate', endDate, 'starttime', startHour);
    
    if ~isempty(phqToday.val) 
        dataByDate(iDay).PHQ9 = phqToday.val;
    end
    
    % Isolate all Mood Zoom data between startDate and endDate
    mzToday = isolateMZDataInDateRange(moodZoom, startDate, ...
        'endDate', endDate, 'starttime', startHour);
    
    if ~isempty(mzToday.val) 
        dataByDate(iDay).MZ = mzToday.val;
    end 
    
    % Isolate all promis data between startDate and endDate
    promisToday = isolatePromisDataInDateRange(promis, startDate, ...
        'endDate', endDate, 'starttime', startHour);
    
    if ~isempty(promisToday.val) 
        dataByDate(iDay).Promis = promisToday.val;
    end  
    
    % Isolate all location data between startDate and endDate
    if ~isempty(location)
        locToday = isolateLocDataInDateRange(location, startDate, ...
            'endDate', endDate, 'starttime', startHour);

        if ~isempty(locToday.lat) 
            dataByDate(iDay).loc = locToday;
        end
    end
    
    % Isolate all call data between startDate and endDate
    if ~isempty(call)
        callToday = isolateCallDataInDateRange(call, startDate, ...
            'endDate', endDate, 'starttime', startHour);

        if ~isempty(callToday.id) 
            [~, idx, ~] = unique(callToday.t);
            callID = callToday.id(idx);
            callType = callToday.type(idx);
            callDur = callToday.dur(idx);
            callTime = callToday.t(idx);
            dataByDate(iDay).callID = callID;
            dataByDate(iDay).callType = callType;    
            dataByDate(iDay).callDur = callDur;
            dataByDate(iDay).callTime = callTime;
        end
    end
    
end % end loop through days

end % end function
