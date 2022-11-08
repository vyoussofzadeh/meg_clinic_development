function clean_events = qrsDet2(ecg, Options)
% qrsDet2: Detect QRS events from ECG signal
%
% USAGE: clean_events = qrsDet2(ecg, Options)
%
% INPUT:    ecg = channel signal containing ECG information
%
%           Options.sampRate        sampling rate of the signal
%           Options.percentThresh   qrs detection threshold (percent)
%           Options.noiseThresh     number of std from mean to include for detection)  
%           Options.maxCrossings    max number of crossings
%           Options.minBeats        minimum number of heartbeats needed for event file
%
% OUTPUT:   clean_events = qrs event times
%
% Author: Elizabeth Bock, 2009
% --------------------------- File History ------------------------------
% EB 27-AUG-2009  Creation
% -------------------------------------------------------------------------

logFile = GUI.MCLogFile;
clean_events = [];

% --------------------- Set up blanking period ----------------------------  
% No events can be detected during the blanking
% period.  This blanking period assumes no heartrate will be faster than
% 120 bpm.
minInterval = round((60*Options.sampRate)/120);
BLANK_PERIOD = minInterval;

% ------------------ Determine the ecg channel ----------------------------
ecgChan = 1;
[row, col] = size(ecg);
% If there is more than one channel labeled as ECG, let the user choose.
if row > 1
    logFile.write('2 ECG Leads Detected')
    % plot 10 secs of each lead
    subplot(2,1,1)
    plot(ecg(1,1:10000))
    hold on
    subplot(2,1,2)
    plot(ecg(2,1:10000))
    
    disp('Two ECG leads were detected, which would you like to use for analysis?')
    reply = input('1 or 2?');
    if reply == 2
        ecgChan = 2;
    else
        ecgChan = 1;
    end
end

% -------------------------- Bandpass filter the signal--------------------
filtecg = bst_bandpass_fft(ecg(ecgChan,:), Options.sampRate, 5, 35);
lenpts = length(filtecg);
% Absolute value
absecg = abs(filtecg);

% -------------------------- Determine threshold --------------------------
init = round(Options.sampRate); % One second
% Find the average of the maximum of each of the first three seconds
maxpt(1) = max(absecg(1:init));
maxpt(2) = max(absecg(init:2*init));
maxpt(3) = max(absecg(init*2:init*3));
init_max = mean(maxpt);
% Threshold is percent of max
thresh_value = Options.percentThresh/100;
qrs_event.thresh1 = init_max*thresh_value;
if qrs_event.thresh1 < 0.02e-3
    return;
end

% ------------------------- Find events -----------------------------------
qrs_event.filtecg = filtecg;
qrs_event.time=[];
k=1;
i=1;

while i < lenpts-BLANK_PERIOD+1
    if absecg(i) > qrs_event.thresh1 % signal exceeds thresh
        window = absecg(i:i+BLANK_PERIOD); 
        [maxPoint, maxTime] = max(window(1:BLANK_PERIOD/2)); % max of the window
        rms = sqrt(mean(window.^2)); % rms of signal for this window
        
        % Find the number of threshold crossings in the window
        x=find(window>qrs_event.thresh1);
        y=diff(x);
        numcross = length(find(y>1))+1;
        
        qrs_event.time(k) = maxTime+i; % time of max value
        qrs_event.ampl(k) = maxPoint; % max value
        qrs_event.numcross(k) = numcross; 
        qrs_event.rms(k) = rms;

        i=i+BLANK_PERIOD; % skip ahead past blank period
        k=k+1; % increment event count
    else
        i=i+1; % increment to next point
    end
end

if ~isempty(qrs_event.time)
    % Exclude events that do not meet noise criteria
    rms_mean = mean(qrs_event.rms); % mean rms of all events
    rms_std = std(qrs_event.rms); % std of rms for all events
    rms_thresh = rms_mean+(rms_std*Options.noiseThresh); % rms threshold
    b = find(qrs_event.rms < rms_thresh); % find events less than rms threshold
    a = qrs_event.numcross(b); 
    c = find(a < Options.maxCrossings); % find events with threshold crosses less than desired value
    clean_events = qrs_event.time(b(c));
end

nBeats = length(clean_events);
logFile.write(['Only ' num2str(nBeats) ' heart beats were detected.  This recording will not be cleaned.']);
if nBeats < Options.minBeats
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, ['Only ' num2str(nBeats) ' heart beats were detected.  This recording will not be cleaned.']);
    clean_events = [];
end




