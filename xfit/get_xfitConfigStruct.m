function sXfit = get_xfitConfigStruct()
% Xfit Configuration Structure

sXfit.fileType = [];              % raw or evoked
sXfit.fileName = [];              % .fif file
sXfit.pathName = [];              % directory where fif file is located
sXfit.xfitPath = [];              % directory to store outputs of dipole fitting process

sXfit.useChSubsets = [];          % Use channel subsets defined in /HOME/.meg_analysis/xfit_selections
sXfit.useGlobalFit = [];
sXfit.isRawEventsDefined = [];    % Run dipole fitting in a specific time window surrounding defined events
sXfit.rawEventFile = [];          % Event file (.eve or -annot.fif)
sXfit.rawEventNumber = [];        % Event number from event file
sXfit.rawEventTimeWin = [];       % [start, end] Offset from event to start and end epoch
sXfit.rawChunkLength = [];        % Length of the raw chunks when no events windows are defined
sXfit.epochDataFile = [];         % Data file containing the epoched data ("chunked raw" or "ave" file)

sXfit.useFilter = [];
sXfit.filterFreq = [];

sXfit.isEvokedTimeDefined = [];   % Run dipole fitting in a specific time window in averaged epoch
sXfit.evokedTimeWin = [];         % [start, end] Offset from event to start and end time window

sXfit.useEvokedBaseline = [];
sXfit.evokedBaselineTime = [];    % [start, end]

sXfit.fitInterval = [];           % Interval for fitting dipoles
sXfit.commandFile = [];       % Output file containing the commands for xfit
sXfit.centerHeadCoord = [];       % [x,y,z] coordinates of the origin of the sphere in the head coordinate system
sXfit.fiffsetup = [];             % [fiffsetup] = fiff_setup_read_raw(filePath); 

sXfit.data = [];        % [data] = fiff_read_evoked_all(filePath);