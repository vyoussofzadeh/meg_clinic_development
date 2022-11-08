% Xfit Configuration Structure

sXfit.fileType              % raw or evoked
sXfit.fileName              % .fif file
sXfit.pathName              % directory where fif file is located
sXfit.xfitPath              % directory to store outputs of dipole fitting process

sXfit.useChSubsets          % Use channel subsets defined in /HOME/.meg_analysis/xfit_selections
sXfit.isRawEventsDefined    % Run dipole fitting in a specific time window surrounding defined events
sXfit.rawEventFile          % Event file (.eve or -annot.fif)
sXfit.rawEventNumber        % Event number from event file
sXfit.rawEventTimeWin       % [start, end] Offset from event to start and end epoch
sXfit.chunkedDataFile       % Output data file containing the epoched data

sXfit.isEvokedTimeDefined   % Run dipole fitting in a specific time window in averaged epoch
sXfit.evokedTimeWin         % [start, end] Offset from event to start and end time window

sXfit.useEvokedBaseline
sXfit.evokedBaselineTime    % [start, end]

sXfit.fitInterval           % Interval for fitting dipoles
sXfit.commandFileName       % Output file containing the commands for xfit
sXfit.centerHeadCoord       % [x,y,z] coordinates of the origin of the sphere in the head coordinate system