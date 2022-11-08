function mc_bst_functional_pipeline(selectedStudies)
% mc_bst_functional_pipeline: run pipeline for functional paradigms 
%
% USAGE:    mc_bst_functional_pipeline(selectedStudies)
%           
% INPUT:    selectedStudies = list of study indices to include in the analysis
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 12-JULY-2011 Creation
% -------------------------------------------------------------------------

% get user input about whether the script needs to adjust time window for different freq band
SpectDecompChoice=input(['Do you want to adjust time window for freq band? (y or n):  ' sprintf('\t')], 's'); 
while ~(strcmpi(SpectDecompChoice,'y') || strcmpi(SpectDecompChoice,'n'))   % string compare ignoring case
    SpectDecompChoice=input(['Only the above two choices are accepted. Please try again:  '],'s'); 
end

%% Compute sources
mc_bst_compute_sources(selectedStudies);

%% Run Brainstorm Processes
eventsToTest = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.FUNCTIONALEVENTS)));
for e = 1:length(eventsToTest)
    categoryKeyword = ['Event #' eventsToTest{e}];
    [DataFiles, ResultFiles] = get_category_files(selectedStudies, categoryKeyword);
    if ~isempty(DataFiles)
        nFiles = num2str(length(DataFiles));
        newComment = ['Avg: Event #' eventsToTest{e} ' ' nFiles ' files'];
        % -----Average time series
        % average_event_data(DataFiles, 1, newComment);
        % -----Average sources
        % sFile = average_event_sources(ResultFiles, 1, newComment);
        % -----Diff between two conditions
        % TO DO
        % -----z-score on average sources
        % zscore_event_sources({sFile.FileName}, [newComment '| band(5-80Hz) zscore']);   
        % -----Spect decomp
        configOptions = BrainstormIO.BstConfig.getConfigOptions();
        ind = double(BrainstormIO.BstConfig.ADJUST_WIN) + 1; % Java uses zero indexing
        if  strcmpi(SpectDecompChoice,'y')   %if configOptions(ind)
            % Use different window lengths based on the median frequency of the bands
            mc_bst_compute_spect_decomp_adjust(selectedStudies,DataFiles);
        else
            % Use epochs
            mc_bst_compute_spect_decomp(selectedStudies,DataFiles);
        end
    end
end
end

%% Average data
function sFile = average_event_data(DataFiles, includeFiltering, newComment)
% average_event_data: call bst_process for averaging event time series 
%
% USAGE:    average_event_data(DataFiles, includeFiltering, newComment)           
% INPUT:    DataFiles = full path to the bst db data files (time series) of the events
%           includeFiltering = boolean to include 5-80Hz filtering
%           newComment = text string with the file comment
% OUTPUT:   sFile = struct containing info about the resulting file

sFile = {};
% Process: Average everything, abs
sFile = bst_process(...
    'CallProcess', 'process_average', ...
    DataFiles, [], ...
    'avgtype', 1, ...
    'isstd', 0, ...
    'Comment', newComment);

% Process: bandpass filter 5-40Hz
if includeFiltering
    FileNamesA = sFile.FileName;
    clear Processes sFile
    newComment = [newComment ' | band(5-80Hz)'];
    sFile = bst_process(...
        'CallProcess', 'process_bandpass', ...
        FileNamesA, [], ...
        'highpass', 5, ...
        'lowpass', 80, ...
        'sensortypes', 'EEG, MEG, MEG MAG, MEG GRAD', ...
        'overwrite', 0, ...
        'Comment', newComment);
end
end


%% Average sources
function sFile = average_event_sources(ResultFiles, includeFiltering, newComment)
% average_event_sources: call bst_process for averaging event source data 
%
% USAGE:    average_event_sources(ResultFiles, includeFiltering, newComment)           
% INPUT:    ResultFiles = full path to the bst db result files (sources) of the events
%           includeFiltering = boolean to include 5-80Hz filtering
%           newComment = text string with the file comment
% OUTPUT:   sFile = struct containing info about the resulting file

sFile = {};
% Process: Average everything, abs
sFile = bst_process(...
    'CallProcess', 'process_average', ...
    ResultFiles, [], ...
    'avgtype', 1, ...
    'abs', 1, ...
    'isstd', 0, ...
    'Comment', newComment);

% Process: bandpass filter 5-40Hz
if includeFiltering
    FileNamesA = sFile.FileName;
    clear Processes sFile
    newComment = [newComment ' | band(5-80Hz)'];
    sFile = bst_process(...
        'CallProcess', 'process_bandpass', ...
        FileNamesA, [], ...
        'highpass', 5, ...
        'lowpass', 80, ...
        'sensortypes', 'EEG, MEG, MEG MAG, MEG GRAD', ...
        'overwrite', 0, ...
        'Comment', newComment);
end
end

%% zscore sources
function sFile = zscore_event_sources(ResultFiles, newComment)
% zscore_event_sources: call bst_process for zscore event source data 
%
% USAGE:    zscore_event_sources(ResultFiles, newComment)           
% INPUT:    ResultFiles = full path to the bst db result files (sources) of events
%           newComment = text string with the file comment
% OUTPUT:   sFile = struct containing info about the resulting file

sFile = {};
% Process: z score normalization [-300ms, 1000ms]
sFile = bst_process(...
    'CallProcess', 'process_zscore3', ...
    ResultFiles, [], ...
    'baseline', [-0.3, 1.0], ...
    'overwrite', 0, ...
    'Comment', newComment);
end