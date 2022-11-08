function mc_bst_interictal_pipeline(selectedStudies)
% mc_bst_interictal_pipeline: run pipeline for interictal spike events 
%
% USAGE:    mc_bst_interictal_pipeline(selectedStudies)
%           
% INPUT:    selectedStudies = list of study indices to include in the analysis
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 12-JULY-2011 Creation
% -------------------------------------------------------------------------

%% Compute sources
mc_bst_compute_sources(selectedStudies);

%% Run Brainstorm Processes
eventsToTest = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.INTERICTALSPIKES)));
for e = 1:length(eventsToTest)
    categoryKeyword = ['Event #' eventsToTest{e}];
    [DataFiles, ResultFiles] = get_category_files(selectedStudies, categoryKeyword);
    if ~isempty(DataFiles)
        nFiles = num2str(length(DataFiles));
        newComment = ['Avg: Event #' eventsToTest{e} ' ' nFiles ' files'];
        % -----Average time series
        average_event_data(DataFiles, 1, newComment);
        % -----Average sources
        %sFile = average_event_sources(ResultFiles, 1, newComment);
        % -----z-score on average sources
        %zscore_event_sources({sFile.FileName}, [newComment '| band(5-40Hz) zscore']);
        % -----recurrence maps
        %newComment = ['RecurrenceMap: Event #' eventsToTest{e} ' ' nFiles ' files'];        
        %recurrence_events(ResultFiles, newComment);      
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
    'avg_func', 1, ...
    'Comment', newComment);

% Process: bandpass filter 5-40Hz
if includeFiltering
    FileNamesA = sFile.FileName;
    clear Processes sFile
    newComment = [newComment ' | band(5-40Hz)'];
    sFile = bst_process(...
        'CallProcess', 'process_bandpass', ...
        FileNamesA, [], ...
        'highpass', 5, ...
        'lowpass', 40, ...
        'mirror', 1, ...
        'overwrite', 1, ...
        'Comment', newComment);
end
end


%% Average sources
% average_event_sources: call bst_process for averaging event source data 
%
% USAGE:    average_event_sources(ResultFiles, includeFiltering, newComment)           
% INPUT:    ResultFiles = full path to the bst db result files (sources) of the events
%           includeFiltering = boolean to include 5-40Hz filtering
%           newComment = text string with the file comment
% OUTPUT:   sFile = struct containing info about the resulting file

function sFile = average_event_sources(ResultFiles, includeFiltering, newComment)
% Process: Average Everything
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
    newComment = [newComment ' | band(5-40Hz)'];
    sFile = bst_process(...
        'CallProcess', 'process_bandpass', ...
        FileNamesA, [], ...
        'highpass', 5, ...
        'lowpass', 40, ...
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

%% recurrence maps
function sFile = recurrence_events(ResultFiles, newComment)
% recurrence_events: call bst_process for recurrence event source data 
%
% USAGE:    recurrence_events(ResultFiles, newComment)           
% INPUT:    ResultFiles = full path to the bst db result files (sources) of events
%           newComment = text string with the file comment
% OUTPUT:   sFile = struct containing info about the resulting file

sFile = {};
% Process: [Experimental] Recurrence maps of activations
sFile = bst_process(...
    'CallProcess', 'process_recurrence2', ...
    ResultFiles, [], ...
    'timewindow', [-0.3, 0.1], ...
    'bandPass1', 5, ...
    'bandPass2', 40);
end