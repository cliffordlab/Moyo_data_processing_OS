function [tOut, xOut, yOut, zOut] = isolateAccDataInDateRange(t, x, y, z, startDate, varargin)

% [tOut, xOut, yOut, zOut] = isolateAccDataInDateRange(t, x, y, z, startDate, varargin)
% 
% Overview
%	Returns accelerometry data (t, x, y, z) between start and end dates.
%     
% Input
%   t [double array]    - timestamps (in seconds; Matlab time format)
%   x [double array]    - accelerometry reading in x-axis
%	y [double array]    - accelerometry reading in y-axis
%   z [double array]    - accelerometry reading in z-axis
%   startDate [double]  - start date in Matlab time
%   'startTime' [double]  - start time in Matlab time
%                         OPTIONAL; default time is 8:00 am
%   'endDate' [double]    - end date in Matlab time
%                         OPTIONAL; default end date is 24 hrs after startDate
%
% Output
%   tOut [double array] - timestamps (in seconds; Matlab time format)
%   xOut [double array] - accelerometry reading in x-axis
%	yOut [double array] - accelerometry reading in y-axis
%   zOut [double array] - accelerometry reading in z-axis
%
% Example
%   [tOut, xOut, yOut, zOut] = isolateAccDataForDate(t, x, y, z, startDate, ...
%       'startTime', asdf, 'endDate', asdf);
%
% Dependencies
%    https://github.com/cliffordlab/
%
% Reference(s)
% 
% Copyright (C) 2017 Erik Reinertsen <er@gatech.edu>
% All rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.


% Check required inputs
if ~isnumeric(t) || ~isnumeric(x) || ...
   ~isnumeric(y) || ~isnumeric(z) || ~isnumeric(startDate)
    error('Error: make sure all required inputs are numeric.');
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
idxWithinDateRange = find(t >= startDate & t < endDate);

% Isolate just the values within the date range, and save to output variables
tOut = t(idxWithinDateRange);
xOut = x(idxWithinDateRange);
yOut = y(idxWithinDateRange);
zOut = z(idxWithinDateRange);

end % end function