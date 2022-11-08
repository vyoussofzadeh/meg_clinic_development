function [uint16Values, times, fiffsetup] = mc_clean_create_evefile(fname, maskVal)
% readSTIchannel_uint16: Get the STI Channel (unsigned) from a FIFF file
%
% EA Bock, 2010
%%
% Read the header
[fiffsetup] = fiff_setup_read_raw(fname);
% Get the sti channel name
channelNames = fiffsetup.info.ch_names;
ch_STI = strmatch('STI101',channelNames);
if isempty(ch_STI)
    % look for the _sss_raw.fif
    [p,n] = fileparts(fname);
    files = dir([p '/*_raw_sss.fif']);
    if isempty(files)
        error('Cannot find the raw sss file to extract events')
    else
        [fiffsetup] = fiff_setup_read_raw([p '/' files(1).name]);
        % Get the sti channel name
        channelNames = fiffsetup.info.ch_names;
        ch_STI = strmatch('STI101',channelNames);
        if isempty(ch_STI)
            error('Cannot extract STI channel')
        end
    end
end

% Get the start and end times
start_samp = fiffsetup.first_samp;
end_samp = fiffsetup.last_samp;
% Get the sti channel values
[sti, times] = fiff_read_raw_segment(fiffsetup, start_samp ,end_samp, ch_STI);
temp = int16(sti);
% typecast to unsigned for the case of 16-bit encoded values
uint16Values = typecast(temp, 'uint16');

[p,n] = fileparts(fname);
[s,sub] = fileparts(p);
saveFile = [p '/' sub '.eve'];
write_eve_file(uint16Values, times, maskVal, saveFile, fiffsetup)