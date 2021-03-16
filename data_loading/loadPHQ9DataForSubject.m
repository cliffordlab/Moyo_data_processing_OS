function phq9 = loadPHQ9DataForSubject(path, pathToRepo)
% 
% Overview
%   Loads all PHQ-9 data for a patient given the path to their data
%   
% Input
%   path [string] - full path to directory with date subdirectories with data
%
% Output
% 
% Copyright (C) 2017 Ayse Cakmak <acakmak3@gatech.edu>
% All rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.

% Initialize moodSwipe as empty array
phq9.t = [];
phq9.val = [];

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

    fprintf('   Processing PHQ-9 files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of PHQ-9 files
    idxMSThisDateDir = find(endsWith({filesInDateDir.name}, {'.phq'}, 'ignorecase', true))';
    
    % If PHQ-9 files exist in this date directory, process them
    if ~isempty(idxMSThisDateDir)

        % Loop through each PHQ-9 file in this date directory
        for k = 1:length(idxMSThisDateDir)

            % Determine full path to k'th PHQ-9 file
            MSFilename = filesInDateDir(idxMSThisDateDir(k)).name;
            fullPathToMS = [pwd, '/', MSFilename];

            fid = fopen(fullPathToMS);
            data = textscan(fid, '%d%d', 'Delimiter', ',', 'HeaderLines', 1);
            phq9.val = [phq9.val; data(2)];
            fclose(fid);

            % Isolate timestamp of when file was written (the last
            % timestamp in the data), and prepend with '1'
            tMS = str2double(['1', strrep(MSFilename, '.phq', '')]); 

            % Convert t_end from millisec to sec (Unix time)
            tMS = tMS / 1000;

            % Save the date of this PHQ-9 in Matlab time,
            phq9.t = [phq9.t; unix2mat(tMS)];
            
        end % end looping through PHQ-9 files
    end % end check if PHQ-9 files exist

    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end % end loop through date directories

cd(pathToRepo)

end % end function
