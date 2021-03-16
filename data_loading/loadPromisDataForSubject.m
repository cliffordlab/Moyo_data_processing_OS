function promis = loadPromisDataForSubject(path, pathToRepo)
% 
% Overview
%   Loads all Promis data for a patient given the path to their data
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
promis.t = [];
promis.val = [];

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

    fprintf('   Processing Promis files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of Promis files
    idxPromisThisDateDir = find(endsWith({filesInDateDir.name}, {'.promis'}, 'ignorecase', true))';
    
    % If promis files exist in this date directory, process them
    if ~isempty(idxPromisThisDateDir)

        % Loop through each MZ file in this date directory
        for k = 1:length(idxPromisThisDateDir)

            % Determine full path to k'th MZ file
            promisFilename = filesInDateDir(idxPromisThisDateDir(k)).name;
            fullPathToPromis = [pwd, '/', promisFilename];
                
            % Load the MZ data into Matlab
            fid = fopen(fullPathToPromis);
            promis.val = [promis.val; textscan(fid, '%f','delimiter', ',')];
            fclose(fid);

            % Isolate timestamp of when file was written (the last
            % timestamp in the data), and prepend with '1'
            tMS = str2double(['1', strtok(promisFilename, '.')]); 

            % Convert t_end from millisec to sec (Unix time)
            tMS = tMS / 1000;

            % Save the date of this promis in Matlab time,
            promis.t = [promis.t; unix2mat(tMS)];
        end 
    end 
    
    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end 

cd(pathToRepo);

end % end function
