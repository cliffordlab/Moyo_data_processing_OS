function [t, x, y, z] = loadAccDataForSubject(path)

% [t, x, y, z] = loadAccDataForSubject(path)
% 
% Overview
%   Loads all ACC data for a patient given the path to their data
%   by looping through all date directories and calling `loadAcc.m`.
%   
% Input
%   path [string] - full path to directory with date subdirectories with data
%
% Output
%   t [double array] - timestamps (in seconds; Matlab time format)
%   x [double array] - accelerometry reading in x-axis
%   y [double array] - accelerometry reading in y-axis
%   z [double array] - accelerometry reading in z-axis
%
% Dependencies
%    https://github.com/cliffordlab/heartFail/loadAcc.m
%
% Reference(s)
% 
% Copyright (C) 2017 Erik Reinertsen <er@gatech.edu>
% All rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.


% Initialize t, x, y, and z as empty arrays
t = [];
x = [];
y = [];
z = [];

% Get names of all date folders in directory
dateDirs = dir(path);

% Remove first two entries because they are '.' and '..'
dateDirs(1:2) = [];

% Remove non-directories from structure
dateDirs(~[dateDirs.isdir]) = [];

% Loop through each date directory
for j = 1:length(dateDirs)

    % Isolate this date directory
    thisDateDir = dateDirs(j).name;

    fprintf('   Processing ACC files in %s\n', thisDateDir);

    % Navigate into date directory
    %cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir([path '/' thisDateDir]);

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of ACC files
    idxAccThisDateDir = find(endsWith({filesInDateDir.name}, {'acc'}, 'ignorecase', true))';

    % If ACC files exist in this date directory, process them
    if ~isempty(idxAccThisDateDir)

        % Loop through each ACC file in this date directory
        for k = 1:length(idxAccThisDateDir)

            % Determine full path to k'th ACC file
            accFilename = filesInDateDir(idxAccThisDateDir(k)).name;
            fullPathToAcc = [thisDateDir, '/', accFilename];

            % Isolate timestamp of when file was written (the last
            % timestamp in the data), and prepend with '1'
            tEndInMs = str2double(['1', strrep(accFilename, '.acc', '')]); % in milliseconds
                
            % Load the ACC data into Matlab
            [tThisAcc, xThisAcc, yThisAcc, zThisAcc] = loadAcc([path '/' fullPathToAcc]);
            
            if isempty(tThisAcc)
                continue;
            end

            % Convert to col vectors
            tThisAcc = tThisAcc(:);
            xThisAcc = xThisAcc(:);
            yThisAcc = yThisAcc(:);
            zThisAcc = zThisAcc(:);
            
            tThisAcc = -1 * tThisAcc + tEndInMs; % Add offset back
            tThisAcc = tThisAcc/1000; % Convert to seconds
            tAbs = unix2mat(tThisAcc);
            
            % Adjust z for gravitational acceleration
            zThisAcc = zThisAcc - 9800;
            
            % Update time and acceleration vectors
            t = [t; tAbs];
            x = [x; xThisAcc];
            y = [y; yThisAcc];
            z = [z; zThisAcc];

        end % end looping through ACC files
    end % end check if ACC files exist
        
end % end loop through date directories

end % end function
