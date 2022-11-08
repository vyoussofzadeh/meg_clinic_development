function eventList = extract_rawFile_events(Events, AcqPars, rawFile, saveFile)
% extract_rawFile_events: reads the STI channels and extracts events that
% are defined in the acquisition parameters.
%
% USAGE:    eventList = extract_rawFile_events(Events, AcqPars, rawFile, saveFile)
%
% INPUT:    Events = Structure containing event information (see parse_aveFile_events())
%           AcqPars = Structure containing acquisition parameters
%           rawFile = raw file containing event info in the STI channel
%           saveFile = name of the .eve file (text file) for saving events
%
% OUTPUT:   eventList = array of events in MNE event text format
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB JULY-2010    Creation
% -------------------------------------------------------------------------

% Get info from raw file
fiffsetup = fiff_setup_read_raw(rawFile);
channelNames = fiffsetup.info.ch_names;
start_samp = fiffsetup.first_samp;
end_samp = fiffsetup.last_samp;

% Get stim channels and masks
if isempty(Events) || isempty(AcqPars)
    % Defaults
    Events(1).eventChannel = 'STI101';
    Events(1).eventNewMask = 65535;
    AcqPars.nCategories = 1;
end

stiCh = unique({Events(1:AcqPars.nCategories).eventChannel});
masks = unique([Events(1:AcqPars.nCategories).eventNewMask]);


%if stim channel 102 is used, extract channel
if strcmp(stiCh, 'STI102')
    ch_STI102 = strmatch('STI102',channelNames);
    [STI102, times102] = fiff_read_raw_segment(fiffsetup, start_samp ,end_samp, ch_STI102);
    temp = int16(STI102);
    val102 = typecast(temp, 'uint16');
end
%if stim channel 101 is used,  Extract STI101
if strcmp(stiCh, 'STI101')
    ch_STI101 = strmatch('STI101',channelNames);
    [STI101, times101]= fiff_read_raw_segment(fiffsetup, start_samp ,end_samp, ch_STI101);
    % Convert to unsigned 16-bit
    temp = int16(STI101);
    values = typecast(temp, 'uint16');
end

% Add the first "dummy" event for MNE format
eventList(1, 1) = start_samp;
eventList(1, 2) = start_samp/fiffsetup.info.sfreq;
eventList(1, 3) = 0;
eventList(1, 4) = 0;
% Keep an index of the events
i=2;

for m=1:length(masks)
    for c = 1:length(stiCh)
        pattern = stiCh(c);
        % find all events that match the stichannel
        x=regexp({Events.eventChannel}, pattern);
        p1=cellfun(@isempty, x);
        % find all events that match the mask
        m1 = [Events.eventNewMask]== masks(m);
        % find all events that meet both criteria
        iEvents = find(~p1 & m1);
        % if there are events that meet the criteria, extract events
        if iEvents
            % Get the mask
            maskVal = Events(iEvents(1)).eventNewMask;
            disp(['mask = ' num2str(maskVal)])
            % Get the sti channel
            if strcmp(Events(iEvents(1)).eventChannel, 'STI101')
                % Create the mask
                mask = uint16(ones(1,length(values))*maskVal);
                out = bitand(mask,values);
                % Find the positive edges ('out' is unsigned)
                events = find(diff(out));
                % Find the values at the edges
                eventVals = out(events+1);
                preEventVals = out(events);
                eventTimes = times101(events+1);
            
            elseif strcmp(Events(iEvents(1)).eventChannel, 'STI102')
                % Create the mask
                mask = uint16(ones(1,length(val102))*maskVal);
                out = bitand(mask,val102);
                % Find the edges
                events = find(diff(out));
                % Find the values at the edges
                eventVals = out(events+1);
                preEventVals = out(events);
                eventTimes = times102(events+1);
            end
            % Collect all events
            disp(['   ' num2str(length(eventVals)) ' events'])
            for n = 1:length(eventVals)
                newEvent = eventTimes(n)*fiffsetup.info.sfreq;
                eventList(i,1) = newEvent;
                eventList(i,2) = eventTimes(n);
                eventList(i,3) = 0; % reference value should be zero to use mne averaging
                eventList(i,4) = eventVals(n);
                i = i+1;
            end
        end            
    end
end

% Sort the event list
sEventList = double(sortrows(eventList));
% Save to a file
fid = fopen(saveFile, 'w');
fprintf(fid, '%7.0f %4.3f %5.0f %5.0f\n',sEventList');
fclose(fid);
end
    