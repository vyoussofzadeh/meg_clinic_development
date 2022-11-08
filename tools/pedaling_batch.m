iname{1} = '/MEG_data/pedaling/ramirez_rey/110211';
iname{2} = '/MEG_data/pedaling/millspaugh_diana/110216';
iname{3} = '/MEG_data/pedaling/arand_brett/110217';
iname{4} = '/MEG_data/pedaling/bao_shancheng/110218';
iname{5} = '/MEG_data/pedaling/promjunyakul_nutta_on/110222';
iname{6} = '/MEG_data/pedaling/fangmann_julie/110309';
iname{7} = '/MEG_data/pedaling/millspaugh_andrew/110301';
iname{8} = '/MEG_data/pedaling/feldhausen_erin/110302';
iname{9} = '/MEG_data/pedaling/straus_steph/110308';
iname{10} = '/MEG_data/pedaling/wrobel_jon/110310';

runs{1} = '/sss/run03_finger/run03_finger_raw_sss.fif';
runs{2} = '/sss/run04_altfinger/run04_altfinger_raw_sss.fif';
runs{3} = '/sss/run05_foot/run05_foot_raw_sss.fif';
runs{4} = '/sss/run06_altfoot/run06_altfoot_raw_defaultHead_sss.fif';

% for i=7:length(iname)
    for i = 6
    for j = 4
        fname = [iname{i} runs{j}];
        pedaling_tappers_extract_events(fname);
        
    end
end
        