function mc_clean_avefxnlruns(varargin)
% mc_clean_avefxnlruns: average events across runs
%
% USAGE:    set(aveRunsButton, 'ActionPerformedCallback', {@mc_clean_avefxnlruns, mc})
%           mc_clean_avefxnlruns(mc)
%           
% INPUT:    mc = megclinic instance
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 25-JULY-2011  Creation
% -------------------------------------------------------------------------
% Parse inputs
% Parse inputs
if nargin > 2
    mc = varargin{3};
else
    mc = varargin{1};
end

outRuns = '';
selectedPaths = mc.getSelectionPaths();  % Java ArrayList
nPaths = selectedPaths.size();
for jj=1:nPaths
    temp = char(selectedPaths.get(jj-1)); % Java uses 0 indexing
    [p,n,e] = fileparts(temp);
    % be sure selected files are average fiff
    if isempty(findstr([n e],'_ave.fif'))
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR,[[n e] ' is not an average fiff file. Select only _ave.fif files and try again'])
        return
    end
    ind = regexp(n,'_');
    outRuns = [outRuns n(1:ind(1))];
    inputPaths(jj) = java.lang.String(temp);
end

files = dir([p '/*_eventInfo.mat']);

% Load AcqPars and Events (info structures)
load([p '/' files(1).name]) % 

% AcqPars details about acq
nEvents = AcqPars.nCategories;
% Events struct details about events
for ii = 1:nEvents
    inputEvents(ii) = java.lang.String([num2str(Events(ii).eventNewBits) ' (' Events(ii).eventName ')']);
end

% Output path - use first selected as reference
temp = char(selectedPaths.get(0)); % Java uses 0 indexing
[p,n,e] = fileparts(temp);
ind = regexp(n,'_');
% create output directory
mkdir([fileparts(p) '/' 'combined/'])
% output name
outName = java.lang.String([fileparts(p) '/' 'combined/combined_' outRuns n(ind(1)+1:length(n)) e]);

configGUI = ArtifactClean.AveFunctionalConfig(inputPaths, inputEvents, outName);
goButton = configGUI.getGoButton();
set(goButton,'ActionPerformedCallback',{@go, configGUI.getInputList, configGUI.getEventList, configGUI.getSavePath});

end

%% Update GUI
function go(varargin)

if nargin > 4
    inputList = varargin{3};
    inputEvents = varargin{4};
    savePath = varargin{5};
else
    inputList = varargin{1};
    inputEvents = varargin{2};
    savePath = varargin{3};
end

% Check for equal number of channels and event types in all files
for ii = 1:length(inputList)
    newData = fiff_read_evoked_all(char(inputList(ii)));
    nChan(ii) = newData.info.nchan;
end

if length(unique(nChan)) > 1
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR,'Files contain different number of channels. Cannot average')
    return
end

% Get the first data file structure for updating
newData = fiff_read_evoked_all(char(inputList(1)));
epochs = [];
nave = [];
for jj = 1:length(inputEvents)
    refEvent = newData.evoked(jj).comment;
    for kk = 1:length(inputList)
        data = fiff_read_evoked_all(char(inputList(kk)));
        % make sure events are the same before averaging
        if strcmp(data.evoked(jj).comment, refEvent)       
            nave(kk) = data.evoked(jj).nave;
            epochs(kk,:,:) = data.evoked(jj).epochs;
        else
            GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR,'Files do not contain similar events for averaging');
            return
        end
    end
    newData.evoked(jj).nave = sum(nave);
    newData.evoked(jj).epochs = squeeze(mean(epochs,1));
    clear epochs nave
end

outFile = char(savePath);
newData.info.filename = outFile;
fiff_write_evoked(outFile,newData);
end