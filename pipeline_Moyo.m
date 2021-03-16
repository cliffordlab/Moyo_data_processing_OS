function pipeline_Moyo(pathToData, pathToRepo, pathToSave)
% 
% Overview
%   This is a pipeline for Moyo Project
%   
%   The script navigates to a directory containing study ID directories,
%   then calls functions that loop through each directory and loads files 
%   into Matlab.
% 
% This software may be modified and distributed under the terms
% of the BSD license.  See the LICENSE file in this repo for details.

% Clean up environment
clc; close all;
cd(pathToRepo);

fprintf('Initializing pipeline to load data for Moyo Project...\n');

% Settings
settings.saveFigures = false;
settings.startHour = 0; % start days at midnight when organizing data by date
settings.plotData = false;

% Add this repo and all sub-directories to Python search path
% Note: have to specificy the full path in a user-agnostic way
if count(py.sys.path, pathToRepo) == 0
    insert(py.sys.path, int32(0), pathToRepo);
end

files = dir(pathToRepo);
dirFlags = find([files.isdir]);

% Save the directory names to a cell array
for k = 1:length(dirFlags)
    dirNames{k} = files(dirFlags(k)).name;
end

% Remote non-directory entries
dirNames(strcmp(dirNames, '.')) = [];
dirNames(strcmp(dirNames, '..')) = [];
dirNames(strcmp(dirNames, '.git')) = [];

% Loop through each directory in the heart_fail repo,
% check if it is on the Python path,
% and if it is not, add it to the path
for k = 1:length(dirNames)
	fullPathToDir = [pathToRepo, '/', dirNames{k}];
    if count(py.sys.path, fullPathToDir) == 0
        insert(py.sys.path, int32(0), fullPathToDir);
    end
end

% Determine subdirectories 
idDirectories = dir(pathToData);
idDirectories = idDirectories([idDirectories.isdir]);
idDirectories = idDirectories(~cellfun('isempty', {idDirectories.date})); 
idDirectories(strncmp({idDirectories.name}, '.', 1)) = [];
idDirectories(strncmp({idDirectories.name}, 'digests', 1)) = [];
idDirectories = {idDirectories.name};
idDirectories = idDirectories(:);

clear idPath; clear id;
idPath = cell(1);
id = cell(1);
j = 1;
% Determine paths in the combination of directories
for i = 1:length(idDirectories)

	idPath{j, 1} = [pathToData, '/', idDirectories{i}];
    
    id{j} = idDirectories{i};
    j = j + 1;
end

% Loop through each subject directory
for i = 1:size(idPath,1)
   
    fprintf('\nLooking at path:  %s.\n', idPath{i,1});
    
    % Initialize structs for subject
    subject = struct();
    t = []; x = []; y = []; z = [];
    moves = struct('val', [], 't', []);
    kccq = struct('summary', [], 't', [], 'pl', [], 'sf', [], 'ql', [], 'sl', []);
    sleeps = struct('val', [], 't', []);
    moodSwipe = struct('val', [], 't', []);
    moodZoom = struct('val', [], 't', []);    
    loc = struct('t', [], 'lat', [], 'lon', []);
    call = struct('t', [], 'type', [], 'id', [], 'dur', []);    
    phq9.val = [];
    phq9.t = [];

    [t, x, y, z] = loadAccDataForSubject(idPath{i,1});
    moodSwipe = loadMSDataForSubject(idPath{i,1},2,pathToRepo);
    moodZoom = loadMZDataForSubject(idPath{i,1},2,pathToRepo);
    loc = loadLocDataForSubject(idPath{i,1},pathToRepo);  
    call = loadCallDataForSubject(idPath{i,1},pathToRepo);
    phq9 = loadPHQ9DataForSubject(idPath{i,1},pathToRepo);
    painSwipe = loadPSDataForSubject(idPath{i,1},pathToRepo);  
    promis = loadPromisDataForSubject(idPath{i,1},pathToRepo);
    qlesq = loadQlesqDataForSubject(idPath{i,1},pathToRepo);
    
    % Re-organize pooled data across all days into a structure array
    % where each element is a structure containing data for a particular date
    subject.dataByDate = organizeDataByDate_Moyo(t, x, y, z, ...
        moodSwipe, moodZoom, kccq, phq9, ...
        loc, call, painSwipe, promis, qlesq, settings.startHour);
    
    subject.ID = id{i};
    
    % Save the file
    save([pathToSave filesep id{i}], 'subject', '-v7.3');   
end 
