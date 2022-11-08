function [Names, eventTypes] = extract_annot_event_types(importFiles)

% Get the sss path
sssPath = char(GUI.DataSet.sssDataPath);
% find all -annot.fif files, these contain the spike events
if isempty(importFiles)
    eventTypes = [];
else
    eventList = [];
    for f = 1:length(importFiles)
        [p,n,e] = fileparts(importFiles{f});
        % find annot files that match the selected file
        [Files, Bytes, Names] = dirr([p '/' n '*-annot.fif'], 'name');
        if isempty(Names)
            % find annot files in the folder
            [Files, Bytes, Names] = dirr([p '/*-annot.fif'], 'name');
        end
        for i = 1:length(Names)        
            events = mne_read_events(Names{i});
            eventList = [eventList events(:,3)'];
        end
    end

    % return the unique event numbers (exclude 0)
    eventTypes = unique(eventList);
    ind = find(eventTypes);
    eventTypes = eventTypes(ind);
end