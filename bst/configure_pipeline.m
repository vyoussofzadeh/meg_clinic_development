function configure_pipeline(varargin)
% configure_pipline: callback function from MEG-Clinic, Batch pipline Configure Button
%
% USAGE:    set(hPiplineConfigButton, 'ActionPerformedCallback', {@configure_pipeline, mc});
%           configure_pipline(mc)
%
% INPUT:   mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2012
% --------------------------- Script History ------------------------------
% EB 2-FEB-2012    Creation
% -------------------------------------------------------------------------
if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

% Instantiate the setup gui
im = mc.getSelectionPaths();
file = char(im.get(0));
spont = char(GUI.DataSet.currentSession.getType(GUI.Session.SPONT));
eve = char(GUI.DataSet.currentSession.getType(GUI.Session.INTERICTALSPIKES));
fxnl = char(GUI.DataSet.currentSession.getType(GUI.Session.FUNCTIONALEVENTS));

% create panel
setup = BrainstormIO.BstBatchTabFrame({file}, cellstr(eve), cellstr(spont), cellstr(fxnl));

% update the events
if isempty(eve)
    path = fileparts(file);
    files = dir(fullfile(path,'*-annot.fif'));
    if ~isempty(files)
        fiffReadEventFile(fullfile(path,files(1).name),setup.getSpikeListModel(),0);
    end
end

if isempty(fxnl)
    path = fileparts(file);
    files = dir(fullfile(path,'*.eve'));
    if ~isempty(files)
        fiffReadEventFile(fullfile(path,files(1).name),setup.getFxnlListModel(),0);
    end
end
    