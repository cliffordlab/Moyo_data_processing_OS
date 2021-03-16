function kccq = loadKCCQDataForSubject(path, pathToRepo)

% kccq = loadKCCQDataForSubject(path)
% 
% Overview
%   Loads all kccq data for a patient given the path to their data
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

% Initialize kccq as empty array
kccq.t = [];
kccq.summary = [];
kccq.sl = [];
kccq.ql = [];
kccq.sf = [];
kccq.pl = [];

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

    fprintf('   Processing KCCQ files in %s\n', thisDateDir);

    % Navigate into date directory
    cd(thisDateDir);

    % Get names of all files in date directory
    filesInDateDir = dir;

    % Remove first two entries because they are '.' and '..'
    filesInDateDir(1:2) = [];

    % Remove directories; we only want files
    filesInDateDir([filesInDateDir.isdir]) = [];

    % Determine indices of kccq files
    idxKccqThisDateDir = find(endsWith({filesInDateDir.name}, {'.kccq'}, 'ignorecase', true))';

    % If kccq files exist in this date directory, process them
    if ~isempty(idxKccqThisDateDir)

        % Loop through each kccq file in this date directory
        for k = 1:length(idxKccqThisDateDir)

            % Determine full path to k'th kccq file
            KCCQFilename = filesInDateDir(idxKccqThisDateDir(k)).name;
            fullPathToKccq = [pwd, '/', KCCQFilename];
            fid = fopen(fullPathToKccq);
            thisKccq = cell2mat(textscan(fid,'%f%f','delimiter',','));
            
            q1 = num2str(thisKccq(1,2));
            q1_1 = str2double(q1(1));
            q1_2 = str2double(q1(2));
            q1_3 = str2double(q1(3));
            % A response of 6 is treated as a missing value
            countPL = 0;
            if q1_1 == 6; q1_1 = 0; countPL = countPL + 1; end
            if q1_2 == 6; q1_2 = 0; countPL = countPL + 1; end
            if q1_3 == 6; q1_3 = 0; countPL = countPL + 1; end
            
            countSF = 0;
            q2 = thisKccq(2,2);
            q3 = thisKccq(3,2);
            q4 = thisKccq(4,2);
            q5 = thisKccq(5,2);
            
            if isempty(q2)
                q2_rescaled = 0;
                countSF = countSF + 1;
            else
                q2_rescaled = 100 * (q2 - 1) / 4;
            end
            
            if isempty(q3)
                q3_rescaled = 0;
                countSF = countSF + 1;
            else
                q3_rescaled = 100 * (q3 - 1) / 6;
            end
            
            if isempty(q4)
                q4_rescaled = 0;
                countSF = countSF + 1;
            else
                q4_rescaled = 100 * (q4 - 1) / 6;
            end
            
            if isempty(q5)
                q5_rescaled = 0;
                countSF = countSF + 1;
            else
                q5_rescaled = 100 * (q5 - 1) / 4;
            end  
            
            countQL = 0;
            q6 = thisKccq(6,2);
            q7 = thisKccq(7,2);
            if isempty(q6); q6 = 0; countQL = countQL + 1; end
            if isempty(q7); q7 = 0; countQL = countQL + 1; end        
               
            q8 = num2str(thisKccq(8,2));
            q8_1 = str2double(q8(1));
            q8_2 = str2double(q8(2));
            q8_3 = str2double(q8(3));
            % A response of 6 is treated as a missing value
            countSL = 0;
            if q8_1 == 6; q8_1 = 0; countSL = countSL + 1; end
            if q8_2 == 6; q8_2 = 0; countSL = countSL + 1; end
            if q8_3 == 6; q8_3 = 0; countSL = countSL + 1; end
            
            missing = 0;
            %% Physical limitation
            if countPL < 2
                pl = 100 * ((q1_1 + q1_2 + q1_3) / (3 - countPL) - 1) / 4;
                kccq.pl = [kccq.pl; pl]; 
            else
                kccq.pl = [kccq.pl; 200]; % Flag: Missing value in PL Q set
                missing = missing + 1;
                pl = 0;
            end
            
            %% Symptom frequency
            if countSF < 3     
                sf = (q2_rescaled + q3_rescaled + q4_rescaled + q5_rescaled) / (4 - countSF);
                kccq.sf = [kccq.sf; sf]; 
            else
                kccq.sf = [kccq.sf; 200]; % Flag: Missing value in SF Q set
                missing = missing + 1;
                sf = 0;
            end
            
            %% Quality of life
            if countQL < 2
                ql = 100 * ((q6 + q7) / (2 - countQL) - 1) / 4;
                kccq.ql = [kccq.ql; ql]; 
            else
                kccq.ql = [kccq.ql; 200]; % Flag: Missing value in QL Q set
                missing = missing + 1; 
                ql = 0;
            end
            
            %% Social limitation
            if countSL < 2
                sl = 100 * ((q8_1 + q8_2 + q8_3) / (3 - countSL) - 1) / 4;
                kccq.sl = [kccq.sl; sl]; 
            else
                kccq.sl = [kccq.sl; 200]; % Flag: Missing value in SL Q set
                missing = missing + 1; 
                sl = 0;
            end
            
            %% Summary score
            if missing < 4
                kccq.summary = [kccq.summary; (pl + sf + ql + sl) / (4 - missing)]; 
            else
                kccq.summary = [kccq.summary; 200]; % Flag: Missing all domains
            end
            
            fclose(fid);
                
            %% Isolate timestamp of when file was written (the last
            % timestamp in the data), and prepend with '1'
            tMS = str2double(['1', strrep(KCCQFilename, '.kccq', '')]); 

            % Convert t_end from millisec to sec (Unix time)
            tMS = tMS / 1000;

            % Save the date of this kccq in Matlab time,
            kccq.t = [kccq.t; unix2mat(tMS)];
            
        end % end looping through kccq files
    end % end check if kccq files exist

    % Navigate back to the ID directory
    cd(fullPathToIdDir);
        
end % end loop through date directories

cd(pathToRepo);

end % end function
