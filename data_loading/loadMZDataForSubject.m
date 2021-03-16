function moodZoom = loadMZDataForSubject(path, directoryNum, pathToRepo)
% 
% Overview
%   Loads all Mood Zoom data for a patient given the path to their data
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


% Initialize moodSwipe as empty array
moodZoom.t = [];
moodZoom.val = [];

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

    fprintf('   Processing MZ files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of MZ files
    if directoryNum == 2
        % There was an error causing some mood zoom files to be saved with
        % .ms extension
        idxMZThisDateDir = find(endsWith({filesInDateDir.name}, {'.ms'}, 'ignorecase', true))';
        idxMZThisDateDir2 = find(endsWith({filesInDateDir.name}, {'.mz'}, 'ignorecase', true))';    
        idxMZThisDateDir = [idxMZThisDateDir(:); idxMZThisDateDir2(:)];
    else
        idxMZThisDateDir = find(endsWith({filesInDateDir.name}, {'.zoom'}, 'ignorecase', true))';
    end
    
    % If MZ files exist in this date directory, process them
    if ~isempty(idxMZThisDateDir)

        % Loop through each MZ file in this date directory
        for k = 1:length(idxMZThisDateDir)

            % Determine full path to k'th MZ file
            MZFilename = filesInDateDir(idxMZThisDateDir(k)).name;
            fullPathToMZ = [pwd, '/', MZFilename];
            
            if directoryNum == 2
                fid = fopen(fullPathToMZ);
                title = fgetl(fid);
                
                % Load the MZ data into Matlab
                if strcmp(title,'Mood')
                    fclose(fid);
                    continue;
                else
                    fid = fopen(fullPathToMZ);
                    moodZoom.val = [moodZoom.val; textscan(fid, '%f','delimiter', ',')];
                    fclose(fid);

                    % Isolate timestamp of when file was written (the last
                    % timestamp in the data), and prepend with '1'
                    tMS = str2double(['1', strtok(MZFilename, '.')]); 

                    % Convert t_end from millisec to sec (Unix time)
                    tMS = tMS / 1000;

                    % Save the date of this MZ in Matlab time,
                    moodZoom.t = [moodZoom.t; unix2mat(tMS)];
                end
            else
                continue; 
            end
        end % end looping through MZ files
    end % end check if MZ files exist

    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end % end loop through date directories

cd(pathToRepo);

end % end function