function sFile = process_event_average(FileNamesA, includeFiltering, newComment)
% process_event_average: Groups similar events and runs bst_batch for
% averaging
%
% USAGE:    process_event_average(FileNamesA, includeFiltering)     
%
% INPUT:    FileNamesA = List of data files to average
%           includeFiltering: 1 = filter average [5,40]Hz, 0 = no filtering
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 19-NOV-2010    Creation
% EB 07-APR-2011    Updated to use brainstorm pipeline file
% -------------------------------------------------------------------------
%% ===== SELECT FILES =====

clear sFile

%% Process: Average Everything
load(fullfile(char(GUI.DataSet.megClinicPath), 'bst_pipelines', 'average_everything.mat'))
sFile = bst_process('CallProcess', Processes, FileNamesA, [], 'Comment', newComment);

%% Process: bandpass filter 5-40Hz
if includeFiltering
    FileNamesA = sFile.FileName;
    clear Processes sFile
    newComment = [newComment ' | band(5-40Hz)'];
    load(fullfile(char(GUI.DataSet.megClinicPath), 'bst_pipelines', 'bpf_5_40Hz.mat'))
    sFile = bst_process('CallProcess', Processes, FileNamesA, [], 'Comment', newComment);
end