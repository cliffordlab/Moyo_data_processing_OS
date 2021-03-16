% 
% Overview
%     Converts json garmin files into csv format
%
% Dependencies
%   https://github.com/cliffordlab/
%
% Reference(s)
%
% Authors
%   Ayse Cakmak <acakmak3@gatech.edu>
% 
% Copyright (C) 2018 Authors, all rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license. See the LICENSE file in this repo for details.
%

jq -r '.[] | [.steps, .distanceInMeters, .durationInSeconds, .activeTimeInSeconds, .startTimeInSeconds, .startTimeOffsetInSeconds, .meanMotionIntensity, .maxMotionIntensity] | @csv' ~/desktop/tonyRaw/1541441405.garmin > ~/desktop/tonyCsv/1541441405.csv
