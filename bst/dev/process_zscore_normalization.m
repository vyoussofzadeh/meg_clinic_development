function sFiles = process_zscore_normalization(FileNamesA, newComment)
% process_event_average: Groups similar events and runs bst_batch for
% averaging
%
% USAGE:    process_event_average(DataFile)     
%
% INPUT:    DataFile = Brainstorm mat file for the study to process
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 19-NOV-2010    Creation
% EB 07-APR-2011    Updated to use brainstorm pipeline file
% -------------------------------------------------------------------------
%% ===== SELECT FILES =====

sFiles = {};

%% Process: z score normalization
load(fullfile(char(GUI.DataSet.megClinicPath), 'bst_pipelines', 'zscore_normalization.mat'))
sFiles = bst_process('CallProcess', Processes, FileNamesA, [], 'Comment', [newComment '| zscore']);

