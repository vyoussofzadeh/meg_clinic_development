
aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run04_flashedattention1/run04_flashedattention1_ave_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
AcqPars.nCategories = 10;
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run04_flashedattention1/run04_flashedattention1_raw_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run06_flashedattention3/run06_flashedattention3_ave_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
AcqPars.nCategories = 10;
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run06_flashedattention3/run06_flashedattention3_raw_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run07_flashedattention4/run07_flashedattention4_ave_defaultHead_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run07_flashedattention4/run07_flashedattention4_raw_defaultHead_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run08_attentiontargeton1/run08_attentiontargeton1_ave_defaultHead_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run08_attentiontargeton1/run08_attentiontargeton1_raw_defaultHead_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run09_attentiontargeton2/run09_attentiontargeton2_ave_defaultHead_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run09_attentiontargeton2/run09_attentiontargeton2_raw_defaultHead_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run10_attentiontargeton3/run10_attentiontargeton3_ave_defaultHead_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run10_attentiontargeton3/run10_attentiontargeton3_raw_defaultHead_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run11_attentiontargeton/run11_attentiontargeton_ave_defaultHead_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run11_attentiontargeton/run11_attentiontargeton_raw_defaultHead_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run03_localizer/run03_localizer_ave_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run03_localizer/run03_localizer_raw_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);

aveFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run02_localizer/run02_localizer_ave_defaultHead_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
AcqPars.nCategories = 10;
rawFile = '/MEG_data/visual_connectome/mathis_jed/100428/sss/run02_localizer/run02_localizer_raw_defaultHead_sss.fif';
extract_rawFile_events(Events, AcqPars, rawFile);