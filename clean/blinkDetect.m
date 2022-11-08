function clean_events = blinkDetect(eog, Options)
% blinkDetect: Detect eye blink events from EOG signal
%
% USAGE: [clean_events, filteog] = blinkDetect(eog, Options)
%
% INPUT:    eog = channel signal containing EOG information
%
%           Options.sampRate        sampling rate of the signal
%           Options.percentThresh   qrs detection threshold (percent)
%           Options.maxCross        max number of crossings
%           Options.minBeats        minimum number of heartbeats needed for event file
%           Options.ampMin          minimum amplitude for detection
%
% OUTPUT:   clean_events = qrs event times
%
% Author: Elizabeth Bock, 2010
% --------------------------- File History ------------------------------
% EB 18-NOV-2010  Creation
% -------------------------------------------------------------------------

logFile = GUI.MCLogFile;

% --------------------- Set up blanking period ----------------------------  
% No events can be detected during the blanking period.
BLANK_PERIOD = 800;

% -------------------------- Bandpass filter the signal--------------------
filteog = bst_bandpass_fft(eog, Options.sampRate, 1.5, 15);
lenpts = length(filteog);
% Absolute value
abseog = abs(filteog);

% -------------------------- Determine threshold --------------------------
if length(abseog) < Options.sampRate*15
    clean_events = [];
    return;
end
init = round(Options.sampRate)*5; % five seconds
% % Find the average of the maximum of each of the first fifteen seconds
maxpt(1) = max(abseog(1:init));
maxpt(2) = max(abseog(init:2*init));
maxpt(3) = max(abseog(init*2:init*3));
init_max = mean(maxpt);
% Calc threshold
thresh_value = Options.percentThresh/100;
thresh1 = init_max*thresh_value;

% ------------------------- Find events -----------------------------------
k=1;
event = [];
i=401;
while i < lenpts-BLANK_PERIOD+1
    if abseog(i) > thresh1 % signal exceeds thresh
        window = abseog(i:i+BLANK_PERIOD); 
        % Find number of peaks
        iTh = find(window > thresh1);
        diTh = diff(iTh);
        iPeak = find(diTh > 1);
        nPeaks = length(iPeak);
        [maxV, maxI] = max(window);
        
        % if the peaks meet the criteria, this is an event
        if nPeaks < Options.maxCross && abs(filteog(i+maxI)) > Options.ampMin
            event(k) = i+maxI;
            k=k+1; % increment event count
        end

        i=i+maxI+BLANK_PERIOD; % skip ahead past blank period

    else
        i=i+1; % increment to next point
    end
end
nBeats = length(event);

logFile.write(['Only ' num2str(nBeats) ' eye blinks were detected.  Projections were not calculated.']);
if nBeats < Options.minBeats
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, ['Only ' num2str(nBeats) ' eye blinks were detected.  Projections were not calculated.']);
    clean_events = [];
else
    clean_events = sortEOGTypes(event, filteog, Options.firstSamp, Options.corrVal);
end
end