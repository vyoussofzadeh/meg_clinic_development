function remove_eog_artifact(mc, FileNames)
% remove_eog_artifact: Get eye blinks and create SSP projection
%
% USAGE:    remove_eog_artifact(mc, FileNames)
%
% INPUT:    mc = megclinic instance
%           FileNames = FileNames structure
%
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 18-NOV-2010  Creation
% -------------------------------------------------------------------------

%% Get eye blink events
eogEveFile = fullfile(FileNames.filelocation, FileNames.eogEventFileName);
fileExists = exist(eogEveFile,'file');
if fileExists == 0
    fiffsetup = fiff_setup_read_raw(FileNames.filename);        
    % Get eog
    eog = get_eog(fiffsetup);
    Options.sampRate = double(fiffsetup.info.sfreq);
    Options.firstSamp = double(fiffsetup.first_samp);
    % Find events
    Options.percentThresh = 80; % Threshold
    Options.ampMin = 85e-6;     % minimum amplitude
    Options.maxCross = 3;       % max threshold crossings
    Options.minBeats = 5;      % min blinks for ssp
    Options.corrVal = 0.5;      % correlation cutoff for sorting
    eog_events = blinkDetect(eog, Options);

    if ~isempty(eog_events)
        mneEvent(1,1) = Options.firstSamp;
        mneEvent(1,2) = Options.firstSamp/Options.sampRate;
        mneEvent(1,3:4) = 0;

        saveEvents = [mneEvent;eog_events];
        eventList(:,1) = saveEvents(:,1);
        eventList(:,2) = saveEvents(:,3);
        eventList(:,3) = saveEvents(:,4);

        % Write to .fif file
        mne_write_events(eogEveFile,eventList);
    end
end

%% Calculate SSP
%check for existing projection and event files
projExists = exist(fullfile(FileNames.filelocation, FileNames.eogProjFileName),'file');
eveExists = exist(fullfile(FileNames.filelocation, FileNames.eogEventFileName), 'file');
if ~projExists
    if eveExists
        % create new ssp operators
        mc.setMessage(GUI.Config.M_MAKE_SSP);
        make_proj_operator(FileNames.filelocation, FileNames.filename, FileNames.eogEventFileName, 'EOG');
        
        projExists = exist(fullfile(FileNames.filelocation, FileNames.eogProjFileName),'file');
        % If the proj file does not exist, then check to be sure MNE named
        % the file correctly.  If not, change the file name.
        if ~projExists
            % find all -proj files for eog
            projFile = dir(fullfile(FileNames.filelocation, ['*' char(ArtifactClean.CleanConfig.EOG_PROJ) '.fif']));
            if isempty(projFile)
                % No proj files for eog exist
                GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, sprintf('%s\n%s','Eye blink projections not created.',' See log for details.'));
            else
                % Find most recent
                dates = {projFile.date};
                [time, mostRecent] = max(datenum(dates));
                projFile = fullfile(FileNames.filelocation,projFile(mostRecent).name);
                % Rename to correct naming convention
                movefile(projFile, fullfile(FileNames.filelocation, FileNames.eogProjFileName));
            end
        end
    else
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, sprintf('%s\n%s','Eye blink events not found.',' Cannot compute projections'));
    end    
else
    disp('Eye blink SSP complete')
end

end