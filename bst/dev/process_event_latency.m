function sFiles = process_event_latency(currentStudyName)
% process_event_latency: Groups similar events and runs bst_batch for
% recurrence maps
%
% USAGE:    process_event_latency(DataFile)     

% INPUT:
%           DataFile = Brainstorm mat file for the study to process
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 20-APR-2010    Creation
% -------------------------------------------------------------------------
%% ===== SELECT FILES =====

[sStudy, iStudy]=bst_get('Study', currentStudyName);
% Find event data

pat='data_Event_*';
x=regexp({sStudy.Data.FileName}, pat);
c=cellfun(@isempty, x);
dataIndices = find(c==0);

% Get event data files
eventData={sStudy.Data(dataIndices).FileName};
temp=char(eventData);
% Sort the event files and determine the event numbers
for j=1:size(temp,1)
    underscores = strfind(temp(j,:),'_');
    numEnd = underscores(length(underscores))-1;
    numStart = underscores(length(underscores)-1)+1;
    eventNumbers(j)=str2num(temp(j,numStart:numEnd));
end
% find unique event types
events = unique(eventNumbers);

% Get the Result file names
ResultFiles = sStudy.Result; 

%% Process: [Experimental] Recurrence maps of activations
load(fullfie(char(GUI.DataSet.megClinicPath), 'bst_pipelines', 'recurrence_maps.mat'))

for n=1:length(events)
    Filenames = eventData((eventNumbers == events(n)));    
    dataIndices = [];
    % Find only those result files that match the raw files
    for i=1:length(Filenames)    
        pat=Filenames(i);
        x=regexp({ResultFiles.FileName}, pat);
        c=cellfun(@isempty, x);
        dataIndices = [dataIndices find(c==0)];
    end

    FileNamesA = {sStudy.Result(dataIndices).FileName};
    FileNamesB = [];
    
    % Process
    sFiles = bst_process('Run', Processes, FileNamesA, FileNamesB);

end
