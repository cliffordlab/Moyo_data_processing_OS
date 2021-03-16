function moodSwipe = loadMSDataForSubject(path, directoryNum, pathToRepo)
% 
% Overview
%   Loads all Mood Swipe data for a patient given the path to their data
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
moodSwipe.t = [];
moodSwipe.val = [];

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

    fprintf('   Processing MS files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of MS files
    if directoryNum == 2
        idxMSThisDateDir = find(endsWith({filesInDateDir.name}, {'.ms'}, 'ignorecase', true))';
    else
        idxMSThisDateDir = find(endsWith({filesInDateDir.name}, {'.swipe'}, 'ignorecase', true))';
    end
    
    % If MS files exist in this date directory, process them
    if ~isempty(idxMSThisDateDir)

        % Loop through each MS file in this date directory
        for k = 1:length(idxMSThisDateDir)

            % Determine full path to k'th MS file
            MSFilename = filesInDateDir(idxMSThisDateDir(k)).name;
            fullPathToMS = [pwd, '/', MSFilename];
            
            if directoryNum == 2
                try
                    fid = fopen(fullPathToMS);
                    title = fgetl(fid);
                    fclose(fid);
                    
                    % Load the MS data into Matlab
                    if ~strcmp(title,'Mood')
                        continue;
                    else
                        fid = fopen(fullPathToMS);
                        try 
                            moodSwipe.val = [moodSwipe.val; cell2mat(textscan(fid, '%f', 1, 'HeaderLines', 1))];
                            fclose(fid);
                        catch
                            continue;
                        end

                        % Isolate timestamp of when file was written (the last
                        % timestamp in the data), and prepend with '1'
                        tMS = str2double(['1', strrep(MSFilename, '.ms', '')]); 

                        % Convert t_end from millisec to sec (Unix time)
                        tMS = tMS / 1000;

                        % Save the date of this MS in Matlab time,
                        moodSwipe.t = [moodSwipe.t; unix2mat(tMS)];
                    end
                catch
                    continue;
                end
            else
                fid = fopen(fullPathToMS);
                r = textscan(fid, '%f%f%f%s%*[^\n]', 'delimiter', ',');
                
                time = cell2str(r{1,4});
                if length(time) > 12   
                    time = datenum(time(3:12));
                    moodSwipe.t = [moodSwipe.t; time];
                    moodSwipe.val = [moodSwipe.val; r{3}];
                    fclose(fid);
                else 
                    fclose(fid);
                    continue;
                end
            end
        end % end looping through MS files
    end % end check if MS files exist

    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end % end loop through date directories

cd(pathToRepo);

end % end function