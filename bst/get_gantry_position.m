function position = get_gantry_position(nosssFile)

nosssFile = '/MEG_data/epilepsy/besser_richard/100128/sss/run01_spont/run01_spont_raw_nosss.fif';

pat='upright';
[fiffsetup] = fiff_setup_read_raw(nosssFile);
descr = {fiffsetup.info.projs.desc};
x=regexp(descr, pat);
c=cellfun(@isempty, x);
dataIndices = find(c==0);

if isempty(dataIndices)
    position = 'supine';
else
    position = 'upright';
end