function remove_ecg_artifact(mc, FileNames)
% remove_ecg_artifact: Get heartbeat events and create an SSP projection
%
% USAGE:    remove_ecg_artifact(mc, FileNames)
%
% INPUT:    mc = megclinic instance
%           FileNames = Filename structure
%
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009  Creation
% -------------------------------------------------------------------------

% ------------- Read the raw file -----------------------------------------
% check to see if ecg event file already exists
checkfile = fullfile(FileNames.filelocation, FileNames.eventFileName);
fileExists = exist(checkfile,'file');
if (fileExists == 0)
    try
        [fiffsetup] = fiff_setup_read_raw(FileNames.filename);
    catch ME
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR, ME.message);
        disp(ME.message)
        return
    end

    [ecg, channelType] = get_ecg(fiffsetup);
    
    if isempty(ecg)
        return;
    end

    Options.sampRate = fiffsetup.info.sfreq;
    firstSamp = fiffsetup.first_samp;

    % -------------- ECG -------------------------------------------------------
    % detect ecg events and write to .eve file
    
    if channelType %MEG
        Options.percentThresh = 90;     %(qrs detection threshold - percent)
        Options.noiseThresh = 2.5;           %(number of std from mean to include for detection)              
        Options.maxCrossings = 3;         %(max number of crossings)
    
    else % ECG
        Options.percentThresh = 60;     %(qrs detection threshold - percent)
        Options.noiseThresh = 2.5;           %(number of std from mean to include for detection)              
        Options.maxCrossings = 3;         %(max number of crossings)
    end

    Options.minBeats = 10;
    Options.ecgType = 999;

    mc.setMessage(GUI.Config.M_MAKE_ECG_EVENTS);
    ecg_events = qrsDet2(ecg, Options);
    % Use all ecg events for ssp and no longer limit the ssp to only 50 events. Used to be:    %% maxEvents = min(50, length(ecg_events));
    maxEvents = length(ecg_events);
    if ~isempty(ecg_events)
        writeEventFile(fullfile(FileNames.filelocation, FileNames.eventFileName), firstSamp, ecg_events(1:maxEvents), Options.ecgType);
        mc.setMessage(GUI.Config.M_ECG_EVENTS_WRITTEN);
    end
end

% -------------- SSP ------------------------------------------------------
% check for existing projection and event files
projExists = exist(fullfile(FileNames.filelocation, FileNames.ecgProjFileName),'file');
eveExists = exist(fullfile(FileNames.filelocation, FileNames.eventFileName), 'file');
if ~projExists
    if eveExists
        % create new ssp operators
        mc.setMessage(GUI.Config.M_MAKE_SSP);
        make_proj_operator(FileNames.filelocation, FileNames.filename, FileNames.eventFileName, 'ECG');
        
        projExists = exist(fullfile(FileNames.filelocation, FileNames.ecgProjFileName),'file');
        % If the proj file does not exist, then check to be sure MNE named
        % the file correctly.  If not, change the file name.
        if ~projExists
            % find all -proj files for ecg
            projFile = dir(fullfile(FileNames.filelocation, ['*' char(ArtifactClean.CleanConfig.ECG_PROJ) '.fif']));
            if isempty(projFile)
                % No proj files for ecg exist
                GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, sprintf('%s\n%s','Heartbeat projections not created.',' See log for details'));
            else
                % Find most recent
                dates = {projFile.date};
                [time, mostRecent] = max(datenum(dates));
                projFile = fullfile(FileNames.filelocation,projFile(mostRecent).name);
                % Rename to correct naming convention
                movefile(projFile, fullfile(FileNames.filelocation, FileNames.ecgProjFileName));
            end
        end
    else
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, sprintf('%s\n%s','Heartbeat events not found.',' Cannot compute projections.'));
    end
    
else
    disp('Heartbeat SSP complete')
end

end
