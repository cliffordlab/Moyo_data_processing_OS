function promisOut = isolatePromisDataInDateRange(promis, startDate, varargin)
% 
% Overview
%	Returns promis survey data between start and end dates.
% 
% Copyright (C) 2017 Erik Reinertsen <er@gatech.edu>
% All rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.


% Check required inputs
if ~isstruct(promis)
    error('Error: make sure all required inputs are in the correct format.');
end

% Intialize default logical checks for input argument
endDateSpecified = false;
startTimeSpecified = false;

% Interpret optional arguments
i = 1;
while i <= length(varargin)
    if ischar(varargin{i})
        switch (lower(varargin{i}))
            case {'enddate'}
                endDate = varargin{i + 1};
                i = i + 1;
                endDateSpecified = true;
            case {'starttime'}
                startTime = varargin{i + 1};
                
                % If startTime is >1, it was given in hour of the day
                % so convert into fraction
                if startTime >1
                    startTime = startTime / 24;
                end
                
                i = i + 1;
                startTimeSpecified = true;
            otherwise
                warning('user entered parameter is not recognized')
                disp('unrecognized term is:'); disp(varargin{k});
        end % end switch
    end % end check if is char
    i = i + 1;
end

% Set default end date to 1 day after startDate
if ~endDateSpecified
    endDate = startDate + 1;
end

% Set default end date to 1 day after startDate
if ~startTimeSpecified
    startTime = 6/24;
end

% Convert startDate into YYMMDD format
startDateYYMMDD = datestr(startDate, 'yymmdd');

% Convert startDateYYMMDD into Matlab datenum format,
% overwrite startDate, and add startTime offset
startDate = datenum(startDateYYMMDD, 'yymmdd') + startTime;

% Convert endDate into YYMMDD format
endDateYYMMDD = datestr(endDate, 'yymmdd');

% Convert endDateYYMMDD into Matlab datenum format,
% overwrite endDate, and add startTime offset
endDate = datenum(endDateYYMMDD, 'yymmdd') + startTime;

% Use find to isolate all timestamps >= startDate and < endDate
idxWithinDateRange = find(promis.t >= startDate & promis.t < endDate);

% Isolate just the values within the date range, and save to output variables
promisOut.t = promis.t(idxWithinDateRange);
promisOut.val = promis.val(idxWithinDateRange);

end % end function