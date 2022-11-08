
aveFile = '/MEG_data/cloze/engmark_charles/091221/sss/run03_cloze_2/run03_cloze_2_ave_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
AcqPars.nCategories = 11;
rawFile = '/MEG_data/cloze/engmark_charles/091221/sss/run03_cloze_2/run03_cloze_2_raw_sss.fif';
logFile = '/MEG_data/cloze/engmark_charles/091221/sss/run03_cloze_2/maxfilter_ave.log';
read_maxave_log

aveFile = '/MEG_data/cloze/engmark_charles/091221/sss/run04_cloze_3/run04_cloze_3_ave_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
AcqPars.nCategories = 11;
rawFile = '/MEG_data/cloze/engmark_charles/091221/sss/run04_cloze_3/run04_cloze_3_raw_sss.fif';
logFile = '/MEG_data/cloze/engmark_charles/091221/sss/run04_cloze_3/maxfilter_ave.log';
read_maxave_log

aveFile = '/MEG_data/cloze/engmark_charles/091221/sss/run5_cloze_run4/run5_cloze_run4_ave_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
AcqPars.nCategories = 11;
rawFile = '/MEG_data/cloze/engmark_charles/091221/sss/run5_cloze_run4/run5_cloze_run4_raw_sss.fif';
logFile = '/MEG_data/cloze/engmark_charles/091221/sss/run5_cloze_run4/maxfilter_ave.log';
read_maxave_log

aveFile = '/MEG_data/cloze/engmark_charles/091221/sss/run6_cloze_run5/run6_cloze_run5_ave_sss.fif';
[Events, AcqPars] = parse_aveFile_events(aveFile);
AcqPars.nCategories = 11;
rawFile = '/MEG_data/cloze/engmark_charles/091221/sss/run6_cloze_run5/run6_cloze_run5_raw_sss.fif';
logFile = '/MEG_data/cloze/engmark_charles/091221/sss/run6_cloze_run5/maxfilter_ave.log';
read_maxave_log