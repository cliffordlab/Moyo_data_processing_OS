function painSwipe = loadPSDataForSubject(path, pathToRepo)
% 
% Overview
%   Loads all Pain Swipe data for a patient given the path to their data
%   
% Input
%   path [string] - full path to directory with date subdirectories with data
%   directoryNum  - We have moodSwipe from va_heartfailure and
%   amoss-mhealth which have different format
%
% Output
% 
% Copyright (C) 2017 Ayse Cakmak <acakmak3@gatech.edu>
% All rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.


% Initialize painSwipe as empty array
painSwipe.t = [];
painSwipe.val = [];

% Navigate into subject subdirectory
cd(path);

% Save full path to ID directory
fullPathToIdDir = pwd;

% Get names of all date folders in directory
dateDirs = dir;

% Remove first two entries because they are '.' and '..'
dateDirs(1:2) = [];

% Remove non-directories from structure
dateDirs(~[dateDirs.isdir]) = [];

% Loop through each date directory
for j = 1:length(dateDirs)

    % Isolate this date directory
    thisDateDir = dateDirs(j).name;

    fprintf('   Processing PS files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of PS files
    idxPSThisDateDir = find(endsWith({filesInDateDir.name}, {'.ps'}, 'ignorecase', true))';
        
    % If PS files exist in this date directory, process them
    if ~isempty(idxPSThisDateDir)

        % Loop through each PS file in this date directory
        for k = 1:length(idxPSThisDateDir)
            
            % Determine full path to k'th PS file
            PSFilename = filesInDateDir(idxPSThisDateDir(k)).name;
            fullPathToPS = [pwd, '/', PSFilename];

            % Load the PS data into Matlab
            fid = fopen(fullPathToPS);
            painSwipe.val = [painSwipe.val; cell2mat(textscan(fid, '%f', 1, 'HeaderLines', 0))];
            fclose(fid);

            % Isolate timestamp of when file was written (the last
            % timestamp in the data), and prepend with '1'
            tMS = str2double(['1', strrep(PSFilename, '.ps', '')]); 

            % Convert t_end from millisec to sec (Unix time)
            tMS = tMS / 1000;

            % Save the date of this PS in Matlab time,
            painSwipe.t = [painSwipe.t; unix2mat(tMS)];

        end 
    end 

    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end 

cd(pathToRepo);

end 