function [t, x, y, z] = loadAcc(path)

% [t, x, y, z] = loadAcc(path)
% 
% Overview
%    Opens a binary ACC file and loads it into Matlab
%     
% Input
%    path [string] - full filepath to single ACC file
%
% Output
%    t [double array] - timestamps (in seconds; Matlab time format)
%    x [double array] - accelerometry reading in x-axis
%    y [double array] - accelerometry reading in y-axis
%    z [double array] - accelerometry reading in z-axis
%
% Dependencies
%
% Reference(s)
% 
% Copyright (C) 2017 Erik Reinertsen <er@gatech.edu>
% All rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.

[~, systemout] = system(['python processaccel.py ', path]);

if isempty(systemout)
    t = []; x = []; y = []; z = [];
    return;
end

systemout_cell = textscan(systemout,'%s','Delimiter','\n');
systemout_cell = systemout_cell{1,1};

output = cellfun(@(s) s(2:end-1), systemout_cell,'UniformOutput',false);
output = sprintf('%s,', output{:});
output = sscanf(output, '%g,', [4, inf]).';

if isempty(output)
    t = []; x = []; y = []; z = [];
    return;
end

% Assign variables
t = output(:,1);
nLines = length(t);

% Initialize variables to store output
t = NaN(nLines, 1);
x = NaN(nLines, 1);
y = NaN(nLines, 1);
z = NaN(nLines, 1);
fileID = fopen(path);

for i = 1:nLines
    
    k = fread(fileID,1,'int32',0,'b');
    if ~isempty(k)
        t(i) = k;
    else
        continue;
    end
    acc = fread(fileID,3,'int16',0,'b');

    x(i) = acc(1);
    y(i) = acc(2);
    z(i) = acc(3);
end

% Close file
fclose(fileID);

x = output(:,2);
y = output(:,3);
z = output(:,4);

% Convert timestamps from milliseconds to sec
%t = t / 1000;

end