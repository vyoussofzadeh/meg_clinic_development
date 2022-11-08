function LI = MEGLImaker(datafilelist)

global GlobalData
LI = [];

% start brainstorm is not started yet
currentProtocol = 'AudDefNaming_study';

%sProtocolInfo = bst_get('ProtocolsListInfo');
sProtocolInfo = GlobalData.DataBase.ProtocolInfo;
nProtocols = length(sProtocolInfo);
iProtocol = 0;
for n=1:nProtocols
    if strcmp(sProtocolInfo(n).Comment, currentProtocol)
        iProtocol = n;
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        break;
    end
end

bst_set('iProtocol',iProtocol)

% for each file in the list
for mm = 1:length(datafilelist)
    selectedFiles = datafilelist(mm).recordings;
    for kk = 1:length(selectedFiles)
        % import data
        [Filenames, iStudy] = importdata(selectedFiles{kk}, iProtocol);
        % compute sources
        li_compute_sources(iStudy);
        % mark noisy trials
        sGoodTrials = detect_bad_trials(Filenames);
        % filter, remove baseline DC
        % Matt! Combine extra events into Event #1 and Event #2
        sFiles(kk).FilesA = preprocess_files(sGoodTrials, 'Event #1');
        sFiles(kk).FilesB = preprocess_files(sGoodTrials, 'Event #2');
        % get sources
        for ii=1:length(sFiles(kk).FilesA)
            [sStudy, iStudy, iResult] = bst_get('ResultsForDataFile', sFiles(kk).FilesA(ii).FileName, iStudy);
            sFiles(kk).SourcesA{ii} = sStudy.Result(iResult).FileName;
        end
        for ii=1:length(sFiles(kk).FilesB)
            [sStudy, iStudy, iResult] = bst_get('ResultsForDataFile', sFiles(kk).FilesB(ii).FileName, iStudy);
            sFiles(kk).SourcesB{ii} = sStudy.Result(iResult).FileName;
        end

        % Averages of within the run
        co=sFiles(1).FilesA(1).Comment;
        comment = ['Avg: ' co(1:regexp(co,'((\W*)')-1) co(regexp(co,'(\W*))')+1:length(co))];
        sAvgFileA = average_files(sFiles(kk).FilesA, comment);
        co=sFiles(1).FilesB(1).Comment;
        comment = ['Avg: ' co(1:regexp(co,'((\W*)')-1) co(regexp(co,'(\W*))')+1:length(co))];
        sAvgFileB = average_files(sFiles(kk).FilesB, comment);

    end

    % average sources across runs
    co=sFiles(1).FilesA(1).Comment;
    comment = ['Avg: ' co(1:regexp(co,'((\W*)')-1) co(regexp(co,'(\W*))')+1:length(co))];
    sAvgSourcesA = average_sources([sFiles.SourcesA], comment);

    co=sFiles(1).FilesB(1).Comment;
    comment = ['Avg: ' co(1:regexp(co,'((\W*)')-1) co(regexp(co,'(\W*))')+1:length(co))];
    sAvgSourcesB = average_sources([sFiles.SourcesB], comment);

    % perform t-test on two conditions
    % Matt doesn't know why this step was included.
    tResultFile = ttest_process([sFiles.SourcesA], [sFiles.SourcesB]);

    % differences of sources
    sDiffSources = difference_sources(sAvgSourcesA, sAvgSourcesB);
    % z-score sources
    zResultFile = zscore_sources(sDiffSources);

    LI(mm) = computeLI(tResultFile, zResultFile);
end

end
%% importdata
function [Filenames, iStudies] = importdata(datafilename, iProtocol)
global GlobalData
iStudies = [];
splitDataFileName = regexp(datafilename,'/','split');
subjectName = splitDataFileName{4};

% Check to see if subject exists
[sSubject, iSubject] = bst_get('SubjectWithName' ,subjectName);

if isempty(iSubject) % Subject does not exist
    [sSubject, iSubject] = mc_bst_create_subject(subjectName);
end

% Import recordings
[path, fileName] = fileparts(datafilename);
sProtocolInfo = GlobalData.DataBase.ProtocolInfo;
studyDir = sProtocolInfo(iProtocol).STUDIES;
currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
[sStudy, iStudy] = bst_get('Study', currentStudyName);
[sSubject, iSubject] = bst_get('SubjectWithName' ,subjectName);

if isempty(sStudy)
    % Set up the import
    ImportOptions.ImportMode = 'Event';
    ImportOptions.UseEvents = 1;
    ImportOptions.EventsTimeRange = [-1, 2]; % epoch time
    ImportOptions.UseSsp = 1;
    ImportOptions.RemoveBaseline = 'time';
    ImportOptions.BaselineRange  = [-1, 0];
    ImportOptions.CreateConditions = 0;
    ImportOptions.GetAllEpochs = 1;
    ImportOptions.Resample = 1;
    ImportOptions.ResampleFreq = [300]; % resample at 300Hz
    ImportOptions.VerifyRegistration = 0;
    ImportOptions.UseCtfComp = 0;

    [p, name, ext] = fileparts(datafilename);
    temp = dir([p '/*.eve']);
    if isempty(temp)
        % create the .eve file (maskVal = 3 for aud def naming)
        eveFile = mc_clean_create_evefile(datafilename, 3);
    else
        evefile = fullfile(p,temp(1).name);
    end
    % Open FIF file, to get the events
    sFile = in_fopen_fif(datafilename, [], 1, evefile);
    fclose(sFile.fid);

    ImportOptions.events = sFile.events;
    ImportOptions.AutoAnswer = 1;

    % import the events
    import_data(sFile, 'FIF', iStudy, iSubject, ImportOptions);
end
[sStudy, iStudy] = bst_get('Study', currentStudyName);
iStudies = [iStudies iStudy];
[sfilelist, ifilelist] = bst_get('Study', iStudy);
Filenames = {sfilelist.Data(:).FileName};
end

%% Compute sources
function li_compute_sources(iStudy)
% -----Check for head model
sStudy = bst_get('Study',iStudy);
disp(sprintf('%s\n','MC>Computing head model...'));
if isempty(sStudy.HeadModel)
    % OVERLAPPING SPHERES
    % Create head modeler panel
    gui_show('panel_headmodel', 'JavaWindow', 'Head modeler');
    % Load study in panel (detect what are the methods that are available)
    panel_headmodel('UpdatePanel', iStudy);
    % Select the method you want to use ('os' stands for 'overlapping spheres')
    panel_headmodel('SetMethod', 'os_meg', [], 'Overlapping spheres');
    % Compute the overlapping sphere model, using the default cortex surface
    % => Other options are: 'Inner skull' (best choice, when you have it), 'Scalp', or 'Outer skull'
    panel_headmodel('ComputeHeadModel');
    %Refresh sStudy
    [sStudy, iStudy] = bst_get('Study', iStudy);
    if isempty(sStudy.HeadModel)
        disp('Error creating head model...skipping');
    end
end

% -----Noise cov
% loads the default
NoiseCovMat = get_default_emptyRoom_noisCov('upright');
[sStudy, iStudy] = bst_get('Study', iStudy);
megCh = sStudy.Channel.nbChannels;
covCh = length(NoiseCovMat.NoiseCov);
% If necessary, adjust matrix size
if megCh < covCh
    % Use only the first megCh x megCh elements
    temp = NoiseCovMat.NoiseCov(1:megCh, 1:megCh);
    NoiseCovMat.NoiseCov = temp;
elseif megCh > covCh
    % Pad the matrix with zeros
    temp = NoiseCovMat.NoiseCov;
    temp(megCh,megCh) = 0;
    NoiseCovMat.NoiseCov = temp;
end

% Import noise cov into current study
AutoReplace = 1;
import_noisecov(iStudy, NoiseCovMat, AutoReplace);
        
% -----Source Estimation
disp(sprintf('%s\n','MC>Estimating sources...'));
dataIndices = [];
if ~isempty(sStudy)
    ResultFiles = sStudy.Result;
    % Filter results
    pat='MN: shared kernel';
    ind=strfind({ResultFiles.Comment}, pat);
    dataIndices = find(~cellfun(@isempty, ind));
end

if isempty(sStudy) || isempty(dataIndices)
    [sStudy, iStudy] = bst_get('Study', iStudy);
    script_minnorm(iStudy, [], 'MN: shared kernel');
end
    
    
end

%% Detect bad trials
function sOutputFiles = detect_bad_trials(Filenames)
% Time window
timewindow   = [-0.6, 0]/1e3;
% MEG MAG
megmag  = {[-4000,4000],0,1e-15};
% Reject entire trial
rejectmode = 2;
% Call process
sOutputFiles = bst_process('CallProcess', 'detectbad', ...  % Name of the process
    Filenames, [], ...            % Files to process
    'timewindow',   [timewindow(1), timewindow(2)],...
    'megmag',megmag,...
    'rejectmode',2,...
    'overwrite',  0);

% Time window
timewindow   = [0, 1500]/1e3;
% MEG MAG
megmag  = {[-8000,8000],0,1e-15};
% Reject entire trial
rejectmode = 2;
% Call process
sOutputFiles = bst_process('CallProcess', 'detectbad', ...  % Name of the process
    sOutputFiles, [], ...            % Files to process
    'timewindow',  [timewindow(1), timewindow(2)],...
    'megmag',megmag,...
    'rejectmode',2,...
    'overwrite',  0);
end

%% pre-process (average, filter, baseline correct)
function sPreProcFiles = preprocess_files(sGoodTrials, pattern)
% find files that match the pattern
x =regexp({sGoodTrials.Comment},pattern);
ind = find(~cellfun(@isempty, x));
sGoodFiles = sGoodTrials(ind);
nFiles = length(sGoodFiles);
newComment = [pattern ' ' num2str(nFiles) ' files'];
                
% Low-pass recordings at 5Hz (no high-pass filter set)
disp('Band-pass filtering')
sBPFiles = bst_process('CallProcess', 'bandpass', ...  % Name of the process
    sGoodFiles, [], ...           % Files to process
    'highpass', 0, 'lowpass', 5, ...  % Bandpass filter
    'overwrite',   0);              % Option: overwrite

disp('Baseline correction')
sPreProcFiles = bst_process('CallProcess', 'baseline', ...  % Name of the process
    sBPFiles, [], ...           % Files to process
    'baseline',[-1, 0], ...  % Bandpass filter
    'overwrite',   1);              % Option: overwrite
end

%% t-test
function ResultFile = ttest_process(FileNamesA, FileNamesB)
% Process: t-test [unequal var, abs(avg)]
sFiles = bst_process(...
    'CallProcess', 'process_ttest', ...
    FileNamesA, FileNamesB, ...
    'testtype', 2, ...
    'avg_func', 2);

% Load the stat file into matlab
statFile = sFiles.FileName;
sProtocolInfo = bst_get('ProtocolInfo');
fileToLoad = fullfile(sProtocolInfo.STUDIES,statFile);
sStat = load(fileToLoad);
% Threshold the tmap
tmap = sStat.tmap;
tmap(tmap < 0) = 0;
% save new tmap to new stat file
sStat.tmap = tmap;
sStat.Comment = 't-test Event #1 vs. Event #2 | thresh>0';
[p,n] = fileparts(fileToLoad);
fileToSave = fullfile(p,[n '_thresh.mat']);
save(fileToSave, '-struct', 'sStat');
% Get the relative path for further bst processing
temp = regexp(fileToSave, sProtocolInfo.STUDIES, 'split');
ResultFile = temp(2);
end

%% Average sensor data
function sAvgFiles = average_files(FilesA, comment)
disp('Averaging')
sAvgFiles = bst_process('CallProcess', 'process_average', ...  % Name of the process
    FilesA, [], ...          % Files to process
    'avgtype', 1, ...  % 1=everything, 2=by subject, 3=by condition
    'Comment', comment);
end

%% Average sources
function sAvgSources = average_sources(sourcesA, comment)
% Process: Average everything, abs
sAvgSources = bst_process(...
    'CallProcess', 'process_average', ...
    sourcesA, [], ...
    'avgtype', 1, ...
    'abs', 1, ...
    'isstd', 0, ...
    'Comment', comment);
end

%% Diff of sources
function sDiffSources = difference_sources(sSourcesA, sSourcesB)
% Process: Difference A-B
sDiffSources = bst_process(...
    'CallProcess', 'process_diff_ab', ...
    sSourcesA, sSourcesB, ...
    'source_abs', 0);

end

%% z-score of sources
function ResultFile = zscore_sources(sSources)
% Process: z score normalization [-300ms, 1000ms]
sZscoreSources = bst_process(...
    'CallProcess', 'process_zscore3', ...
    sSources, [], ...
    'baseline', [-1, 0], ...
    'overwrite', 0);

% Load the z-score file into matlab
zFile = sZscoreSources.FileName;
sProtocolInfo = bst_get('ProtocolInfo');
fileToLoad = fullfile(sProtocolInfo.STUDIES,zFile);
sResult = load(fileToLoad);
% Threshold the zmap
zmap = sResult.ImageGridAmp;
zmap(zmap < 0) = 0;
% Save new zmap to results file
sResult.ImageGridAmp = zmap;
sResult.Comment = 'Event #1 - Event #2 | zscore | thresh>0';
[p,n] = fileparts(fileToLoad);
fileToSave = fullfile(p,[n '_thresh.mat']);
save(fileToSave, '-struct', 'sResult');
% Get the relative path for further bst processing
temp = regexp(fileToSave, sProtocolInfo.STUDIES, 'split');
ResultFile = temp(2);
end

function do_nothing
%% ===== DISPLAY RECORDINGS =====
if 0% Get he average of the Right condition from the list of output files from the averaging process
    iAvgRight = find(~cellfun(@(c)isempty(strfind(c,'Right')), {sAvgFiles.FileName}));
    AvgRightFile = sAvgFiles(iAvgRight).FileName;
    % Same for Left condition (useful for later)
    iAvgLeft = find(~cellfun(@(c)isempty(strfind(c,'Left')), {sAvgFiles.FileName}));
    AvgLeftFile = sAvgFiles(iAvgLeft).FileName;
    % Display first trial in Right condition
    hFigTs = view_timeseries(AvgRightFile, 'MEG');
    % Set time series display mode to: Columns
    gui_brainstorm('SetTsDisplayMode', 'column');
    % Set channel selections to "Left-temporal"
                               bst_selections('SetCurrentSelection', 'Left-temporal');
                               % Display all possible topography modes for the average: MAGNETOMATERS ONLY
                               hFigTp1 = view_topography(AvgRightFile, 'MEG MAG', '2DSensorCap');
                               % hFigTp2 = view_topography(AvgRightFile, 'MEG MAG', '3DSensorCap');
                               % hFigTp3 = view_topography(AvgRightFile, 'MEG MAG', '2DDisc');
                               % hFigTp4 = view_topography(AvgRightFile, 'MEG MAG', '2DLayout');
                               % Pause and close all figures (unload all the loaded datasets)
                               pause(1);
                           end

bst_memory('UnloadAll', 'Forced');

end



