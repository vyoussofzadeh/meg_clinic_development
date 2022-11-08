%get STI101 as uint16
% Get info from raw file
fiffsetup = fiff_setup_read_raw(rawFile);
channelNames = fiffsetup.info.ch_names;
start_samp = fiffsetup.first_samp;
end_samp = fiffsetup.last_samp;

% Extract STI101
ch_STI101 = strmatch('STI101',channelNames);
[STI101, times101]= fiff_read_raw_segment(fiffsetup, start_samp ,end_samp, ch_STI101);

for i=1:length(STI101)
    d(i) = STI101(i);
    if d(i) < 1
        d(i) = abs(d(i))+32768;
    end
end

plot(d);