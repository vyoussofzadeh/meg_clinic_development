function pedaling_tappers_extract_events(fname)
% Get the STI Channel

% The recording name...
% fname = '/MEG_data/pedaling/wrobel_jon/110310/sss/run03_finger/run03_finger_raw_sss.fif';
% fname = '/MEG_data/pedaling/wrobel_jon/110310/sss/run04_altfinger/run04_altfinger_raw_sss.fif';
% fname = '/MEG_data/pedaling/wrobel_jon/110310/sss/run05_foot/run05_foot_raw_sss.fif';
% fname = '/MEG_data/pedaling/wrobel_jon/110310/sss/run06_altfoot/run06_altfoot_raw_sss.fif';

% fname = '/MEG_data/pedaling/ramirez_rey/110211/sss/run05_foot/run05_foot_raw_sss.fif';

[fiffsetup] = fiff_setup_read_raw(fname,1);
[values, times] = readSTIchannel_uint16(fname);

% Get transitions
% maskVal = 61440;
maskVal = 7;
out = bitand(values, maskVal);
% Find the positive edges ('out' is unsigned)
diffEv = diff(out);
% Find the values at the edges
ind = find(diffEv);
eventVals = diffEv(ind);
preEventVals = out(ind);
eventTimes = times(ind);

% Get all events in the MNE format
% Add the first "dummy" event for MNE format
eventList(1, 1) = fiffsetup.first_samp;
eventList(1, 2) = fiffsetup.first_samp/fiffsetup.info.sfreq;
eventList(1, 3) = 0;
eventList(1, 4) = 0;
% Keep an index of the events
i=2;
for n = 1:length(eventVals)
    newEvent = eventTimes(n)*fiffsetup.info.sfreq;
    eventList(i,1) = newEvent;
    eventList(i,2) = eventTimes(n);
    eventList(i,3) = 0; % reference value should be zero to use mne averaging
    eventList(i,4) = eventVals(n);
    i = i+1;
end

% Sort the event list
sEventList = double(sortrows(eventList));
% Save to a file
saveFile = [fname(1:length(fname)-4) '_tapping.eve'];
fid = fopen(saveFile, 'w');
fprintf(fid, '%7.0f %4.3f %5.0f %5.0f\n',sEventList');
fclose(fid);
clear eventList
        clear fname