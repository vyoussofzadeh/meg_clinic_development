function [uint16Values, times, fiffsetup] = mc_clean_create_evefile(fname)
% readSTIchannel_uint16: Get the STI Channel (unsigned) from a FIFF file
%
% EA Bock, 2010
%%
% Read the header
[fiffsetup] = fiff_setup_read_raw(fname);
% Get the sti channel name
channelNames = fiffsetup.info.ch_names;
ch_STI = strmatch('STI101',channelNames);
% Get the start and end times
start_samp = fiffsetup.first_samp;
end_samp = fiffsetup.last_samp;
% Get the sti channel values
[sti, times] = fiff_read_raw_segment(fiffsetup, start_samp ,end_samp, ch_STI);
temp = int16(sti);
% typecast to unsigned for the case of 16-bit encoded values
uint16Values = typecast(temp, 'uint16');