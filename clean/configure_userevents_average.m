function configure_userevents_average()
% configure_userevents_average: callback function from MEG-Clinic, create
% average description file for user events
%
% USAGE:    set(cfitConfigButton, 'ActionPerformedCallback', {@configure_cfit, mc});
%           configure_cfit(mc)
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

if strfind(name, '_ave')
    type = 'evoked';
else
    type = 'raw';
end

setup = DipoleFit.CfitConfigSetup(type, [name ext], path);

% Set callback for getting event file
getEventsButton = setup.getMatlabCallbackButton();
set(getEventsButton, 'ActionPerformedCallback', @(h,v)fiffReadEventFile(setup));

% Check for events and load the file and event number
if setup.isRawEventTimeWindow
    setup.selectRawEventTimeWindow();
end