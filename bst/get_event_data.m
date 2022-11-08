function [eventData, eventNumbers] = get_event_data(sStudy)
% get_event_data: gets the data filenames and event numbers that are loaded
% for a specified study
%
% USAGE:    [eventData, eventNumbers] = get_event_data(sStudy)
%
% INPUT:    sStudy = brainstorm study 
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 28-APRIL-2011    Creation
% -------------------------------------------------------------------------

% Find event data
pat='data_Event_*';
x=regexp({sStudy.Data.FileName}, pat);
c=cellfun(@isempty, x);
dataIndices = find(c==0);
if isempty(dataIndices)
    return;
end

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