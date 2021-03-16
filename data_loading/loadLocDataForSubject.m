function Location = loadLocDataForSubject(path,pathToRepo)
% 
% Overview
%   Loads all location data for a patient given the path to their data
%   
% Input
%   path [string] - full path to directory with date subdirectories with data
%   Format is [timestamp,lat,lon,altitude] 
%
% Output
% 
% Copyright (C) 2017 Ayse Cakmak <acakmak3@gatech.edu>
% All rights reserved.
%
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.


% Initialize moodSwipe as empty array
Location.t = [];
Location.lat = [];
Location.lon = [];

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

    fprintf('   Processing location files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of location files
    idxLocThisDateDir = find(endsWith({filesInDateDir.name}, {'.loc'}, 'ignorecase', true))';
    
    % If location files exist in this date directory, process them
    if ~isempty(idxLocThisDateDir)

        % Loop through each location file in this date directory
        for k = 1:length(idxLocThisDateDir)

            % Determine full path to k'th location file
            LocFilename = filesInDateDir(idxLocThisDateDir(k)).name;
            fullPathToLoc = [pwd, '/', LocFilename];
            
            fid = fopen(fullPathToLoc);
            data = cell2mat(textscan(fid, '%f%f%f%f','Delimiter',','));
            
            if isempty(data)
                continue;
            end
            
            Location.lat = [Location.lat; data(:,2)];
            Location.lon = [Location.lon; data(:,3)];                    
            fclose(fid);

            % Isolate timestamp of when file was written (the last
            % timestamp in the data), and prepend with '1'
            tMS = data(:,1); 

            % Convert t_end from millisec to sec (Unix time)
            tMS = tMS / 1000;

            % Save the date of this loc in Matlab time
            Location.t = [Location.t; unix2mat(tMS)];
            
        end % end looping through loc files
    end % end check if loc files exist

    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end % end loop through date directories

cd(pathToRepo);

end % end function