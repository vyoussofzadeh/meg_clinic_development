function build_xfitCommand_files(varargin)
% build_xfitCommand_files: callback function from MEG-Clinic, Wrapper for
% creating command Files
%
% USAGE:    set(cfitButton, 'ActionPerformedCallback', {@build_xfitCommand_files, mc});
%           build_xfitCommand_files(mc)
%
% INPUT:    mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 2-MARCH-2011    Creation
% -------------------------------------------------------------------------

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

%% Call process_xfit_input() for each event type
% Get configs from MEG-Clinic 
cfitConfig = DipoleFit.CfitConfig;
type = char(cfitConfig.EVE_NUM);
wf = GUI.DataSet.currentWorkflow;

%Get all event types
name = char(cfitConfig.EVE_FILE);

if isempty(name)
    % No event file is selected
    process_xfit_input(mc);
    return
end

if strfind(name,'.fif')
    events = mne_read_events(name);
else
    events = load(name);
end

numbers = int32(events(:,size(events,2)));
eveTypes = unique(numbers);
% Save event types in xml file
if strcmp(char(wf.getName(GUI.WorkflowConfig.EVENTLIST)), '')
    eventList = eveTypes(find(eveTypes))';
    temp = strrep(num2str(eventList),'  ', ',');
    wf.setType(GUI.WorkflowConfig.EVENTLIST, temp);
    wf.save;
end


if strcmp(type, 'All')    
    % Create a command file for each event type
    for i = 1:length(eveTypes)
        if eveTypes(i) > 0
            cfitConfig.EVE_NUM = java.lang.String.valueOf(eveTypes(i));
            process_xfit_input(mc);
        end
    end
else
    %Only one event type or no event type is selected
    process_xfit_input(mc);
end

