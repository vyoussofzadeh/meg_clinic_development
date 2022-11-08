function [sFiles, events] = batch_event_average(currentStudyName)
% batch_event_average: average each event type in a given study
%
% USAGE:    batch_event_average(currentStudyName) - use this to average each event type in a study
%
% INPUT:    currentStudyName - name of the study
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 28-APR-2011    Creation
% -------------------------------------------------------------------------
%% ===== SELECT FILES =====

clear sFiles
[sStudy, iStudy]=bst_get('Study', currentStudyName);

% Find all loaded event datas
[eventData, eventNumbers] = get_event_data(sStudy);

% find unique event types
events = unique(eventNumbers);

% average files for each event type
for n=1:length(events)
    FileNamesA = eventData((eventNumbers == events(n)));
    sFiles(n) = process_event_average(FileNamesA,1);
end
