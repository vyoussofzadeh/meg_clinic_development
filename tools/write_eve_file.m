function write_eve_file(uint16Values, times, maskVal, saveFile, fiffsetup)
% write_eve_file: write an MNE-format eve file from the STI channel
%
% Inputs:   uint16Values - STI channel typecast to unsigned integers (see
%                           readSTIchannel_uint16.m)
%           times - STI channel time values
%           maskVal - mask value to extract desired events
%           saveFile - name of the file ending in .eve
%           fiffsetup - raw file header info (see fiff_setup_read_raw.m)
%
% EA Bock, 2010
%%
% Get transitions
out = bitand(uint16Values, maskVal);
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
fid = fopen(saveFile, 'w');
fprintf(fid, '%7.0f %4.3f %5.0f %5.0f\n',sEventList');
fclose(fid);
