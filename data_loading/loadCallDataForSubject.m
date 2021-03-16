function call = loadCallDataForSubject(path, pathToRepo)
% 
% Overview
%   Loads all phone call data for a patient given the path to their data
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


% Initialize call as empty array
call.t = [];
call.type = [];
call.id = [];
call.dur = [];

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

    fprintf('   Processing call files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of call files
    idxCallThisDateDir = find(endsWith({filesInDateDir.name}, {'.call'}, 'ignorecase', true))';
    
    % If location files exist in this date directory, process them
    if ~isempty(idxCallThisDateDir)

        % Loop through each location file in this date directory
        for k = 1:length(idxCallThisDateDir)

            % Determine full path to k'th call file
            CallFilename = filesInDateDir(idxCallThisDateDir(k)).name;
            fullPathToCall = [pwd, '/', CallFilename];
            
            fid = fopen(fullPathToCall);
            data = textscan(fid, '%s %s %s %s','Delimiter',',','HeaderLines', 1);
            if isempty(data{1})
                fclose(fid);
                continue;
            end
            
            time = [];
            idx = 1;
            id = cell(1);
            type = cell(1);
            dur = [];
            for iTime = 1:length(data{3})   
                timeStr = split(data{3}(iTime));
                
                if length(timeStr) < 6
                    continue;
                end
                
                timeStr = [timeStr{3},'-',timeStr{2},'-',timeStr{6},' ',timeStr{4}];
                
                time(idx,1) = datenum(timeStr);
                id{idx,1} = data{1}{iTime};
                type{idx,1} = data{2}{iTime};
                dur(idx,1) = str2double(data{4}{iTime});
                idx = idx + 1;
            end
            
            call.id = [call.id; id];
            call.type = [call.type; type];                    
            call.t = [call.t; time];
            call.dur = [call.dur; dur];
            fclose(fid);
        end 
    end 

    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end % end loop through date directories

cd(pathToRepo);

end % end function