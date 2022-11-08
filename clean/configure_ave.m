function configure_ave(varargin)
% configure_cfit: callback function from MEG-Clinic, user events averaging
%
% USAGE:    set(cfitConfigButton, 'ActionPerformedCallback', {@configure_ave, mc});
%           configure_ave(mc)
%
% INPUT:   mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 20-APR-2010    Creation
% EB 25-MAY-2010    Updates for callback
% -------------------------------------------------------------------------

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

% Instantiate the setup gui
try
    filename = char(mc.getInfo(GUI.Config.I_SELECTEDFILE));
catch
    GUI.ErrorMessage(GUI.ErrorMessage.WRONG_FILE_TYPE, 'SSS');
    return
end

% Selected file must an 'sss' file
index1 = strfind(filename,'_sss');
index2 = strfind(filename, '_tsss');
index3 = strfind(filename, '_cHPIsss');

if isempty(index1) && isempty(index2) && isempty(index3)
    GUI.ErrorMessage(GUI.ErrorMessage.WRONG_FILE_TYPE, 'SSS');
    return
end

filelocation = char(mc.getInfo(GUI.Config.I_FILE_LOCATION));
if strcmp(filelocation, 'null')
    GUI.ErrorMessage(GUI.ErrorMessage.FILE_LOCATION_NOT_FOUND, '');
    return
end

[path, name, ext] = fileparts(filename);
setup = ArtifactClean.AveDescriptionConfig([name ext], path);

% Set callback for updating with FIFF events
getEventsButton = GUI.CallbackInterface.getEventsFIFF;
set(getEventsButton, 'ActionPerformedCallback', @(h,v)update_FIFF_events(setup));

end

%% Update with FIFF events
function update_FIFF_events(setup)

eveName = char(setup.getEventsFile());
events = mne_read_events(eveName);

numbers = int32(events(:,size(events,2)));
eveTypes = unique(numbers);
eve = cellstr(num2str(eveTypes(find(eveTypes))));
setup.updateCategories(eve);
end