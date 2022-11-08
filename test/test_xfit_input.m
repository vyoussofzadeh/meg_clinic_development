function test_xfit_input(mc)
%The result will be .cfit files and instances of xfit
%Load each xfit with a different .cfit

cfitConfig = DipoleFit.CfitConfig;
%% Raw, subsets+Global, events (.eve)
cfitConfig.TYPE = java.lang.String.valueOf('raw');
cfitConfig.NAME = java.lang.String.valueOf('run01_spont_raw_sss_ecgClean_raw.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 1;
cfitConfig.GLOBAL_SUBSET = 1;
cfitConfig.RAW_TIME_WIN = 1;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_Beth.eve');
cfitConfig.EVE_NUM = java.lang.String.valueOf('1000');
cfitConfig.EVE_START = java.lang.String.valueOf('-50');
cfitConfig.EVE_END = java.lang.String.valueOf('50');

process_xfit_input(mc)

%% Raw, subsets noGlobal, events (.eve)
cfitConfig.TYPE = java.lang.String.valueOf('raw');
cfitConfig.NAME = java.lang.String.valueOf('run01_spont_raw_sss_ecgClean_raw.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 1;
cfitConfig.GLOBAL_SUBSET = 0;
cfitConfig.RAW_TIME_WIN = 1;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_Beth.eve');
cfitConfig.EVE_NUM = java.lang.String.valueOf('1000');
cfitConfig.EVE_START = java.lang.String.valueOf('-50');
cfitConfig.EVE_END = java.lang.String.valueOf('50');

process_xfit_input(mc)
%% Raw, no subsets, events (.eve)
cfitConfig.TYPE = java.lang.String.valueOf('raw');
cfitConfig.NAME = java.lang.String.valueOf('run01_spont_raw_sss_ecgClean_raw.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 0;
cfitConfig.GLOBAL_SUBSET = 1;
cfitConfig.RAW_TIME_WIN = 1;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_Beth.eve');
cfitConfig.EVE_NUM = java.lang.String.valueOf('1000');
cfitConfig.EVE_START = java.lang.String.valueOf('-50');
cfitConfig.EVE_END = java.lang.String.valueOf('50');

process_xfit_input(mc)

%% Raw, subsets+Global, no events (.eve)
cfitConfig.TYPE = java.lang.String.valueOf('raw');
cfitConfig.NAME = java.lang.String.valueOf('run01_spont_raw_sss_ecgClean_raw.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 1;
cfitConfig.GLOBAL_SUBSET = 1;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');

process_xfit_input(mc)

%% Raw, no subsets, no events (.eve)
cfitConfig.TYPE = java.lang.String.valueOf('raw');
cfitConfig.NAME = java.lang.String.valueOf('run01_spont_raw_sss_ecgClean_raw.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 0;
cfitConfig.GLOBAL_SUBSET = 0;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');

process_xfit_input(mc)

% %% Raw, subsets, events (.fif)
% cfitConfig.TYPE = java.lang.String.valueOf('raw');
% cfitConfig.NAME = java.lang.String.valueOf('run01_spont_raw_sss_ecgClean_raw.fif');
% cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont');
% cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('1');
% cfitConfig.CH_SUBSET = 1;
% cfitConfig.RAW_TIME_WIN = 1;
% cfitConfig.EVOKED_TIME_WIN = 0;
% cfitConfig.EVE_FILE = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_spont_raw_sss_ecgClean_raw-annot.fif');
% cfitConfig.EVE_NUM = java.lang.String.valueOf('2000');
% cfitConfig.EVE_START = java.lang.String.valueOf('-1');
% cfitConfig.EVE_END = java.lang.String.valueOf('10');
% 
% process_xfit_input(mc)
% 
% %% Raw, no subsets, events (.fif)
% cfitConfig.TYPE = java.lang.String.valueOf('raw');
% cfitConfig.NAME = java.lang.String.valueOf('run01_spont_raw_sss_ecgClean_raw.fif');
% cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont');
% cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('1');
% cfitConfig.CH_SUBSET = 0;
% cfitConfig.RAW_TIME_WIN = 1;
% cfitConfig.EVOKED_TIME_WIN = 0;
% cfitConfig.EVE_FILE = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_spont_raw_sss_ecgClean_raw-annot.fif');
% cfitConfig.EVE_NUM = java.lang.String.valueOf('2000');
% cfitConfig.EVE_START = java.lang.String.valueOf('-1');
% cfitConfig.EVE_END = java.lang.String.valueOf('10');
% 
% process_xfit_input(mc)

%% Evoked, subsets+global, time window
cfitConfig.TYPE = java.lang.String.valueOf('evoked');
cfitConfig.NAME = java.lang.String.valueOf('Run02_lefthandmovementtovisualcue_raw_tsss_ecgClean_ave.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/Run02_lefthandmovementtovisualcue');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 1;
cfitConfig.GLOBAL_SUBSET = 1;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 1;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');
cfitConfig.BASELINE = 1;
cfitConfig.BASE_START = java.lang.String.valueOf('-200');
cfitConfig.BASE_END = java.lang.String.valueOf('0');
cfitConfig.WIN_START = java.lang.String.valueOf('-1');
cfitConfig.WIN_END = java.lang.String.valueOf('100');

process_xfit_input(mc)

%% Evoked, subsets no global, time window
cfitConfig.TYPE = java.lang.String.valueOf('evoked');
cfitConfig.NAME = java.lang.String.valueOf('Run02_lefthandmovementtovisualcue_raw_tsss_ecgClean_ave.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/Run02_lefthandmovementtovisualcue');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 1;
cfitConfig.GLOBAL_SUBSET = 0;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 1;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');
cfitConfig.BASELINE = 1;
cfitConfig.BASE_START = java.lang.String.valueOf('-200');
cfitConfig.BASE_END = java.lang.String.valueOf('0');
cfitConfig.WIN_START = java.lang.String.valueOf('-1');
cfitConfig.WIN_END = java.lang.String.valueOf('100');

process_xfit_input(mc)
%% Evoked, subsets+global, no time window
cfitConfig.TYPE = java.lang.String.valueOf('evoked');
cfitConfig.NAME = java.lang.String.valueOf('Run02_lefthandmovementtovisualcue_raw_tsss_ecgClean_ave.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/Run02_lefthandmovementtovisualcue');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 1;
cfitConfig.GLOBAL_SUBSET = 1;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');
cfitConfig.BASELINE = 1;
cfitConfig.BASE_START = java.lang.String.valueOf('-200');
cfitConfig.BASE_END = java.lang.String.valueOf('0');
cfitConfig.WIN_START = java.lang.String.valueOf('');
cfitConfig.WIN_END = java.lang.String.valueOf('');

process_xfit_input(mc)

%% Evoked, subsets no global, no time window
cfitConfig.TYPE = java.lang.String.valueOf('evoked');
cfitConfig.NAME = java.lang.String.valueOf('Run02_lefthandmovementtovisualcue_raw_tsss_ecgClean_ave.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/Run02_lefthandmovementtovisualcue');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 1;
cfitConfig.GLOBAL_SUBSET = 0;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');
cfitConfig.BASELINE = 1;
cfitConfig.BASE_START = java.lang.String.valueOf('-200');
cfitConfig.BASE_END = java.lang.String.valueOf('0');
cfitConfig.WIN_START = java.lang.String.valueOf('');
cfitConfig.WIN_END = java.lang.String.valueOf('');

process_xfit_input(mc)

%% Evoked, no subsets, time window
cfitConfig.TYPE = java.lang.String.valueOf('evoked');
cfitConfig.NAME = java.lang.String.valueOf('Run02_lefthandmovementtovisualcue_raw_tsss_ecgClean_ave.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/Run02_lefthandmovementtovisualcue');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 0;
cfitConfig.GLOBAL_SUBSET = 1;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 1;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');
cfitConfig.BASELINE = 1;
cfitConfig.BASE_START = java.lang.String.valueOf('-200');
cfitConfig.BASE_END = java.lang.String.valueOf('0');
cfitConfig.WIN_START = java.lang.String.valueOf('-1');
cfitConfig.WIN_END = java.lang.String.valueOf('100');

process_xfit_input(mc)

%% Evoked, no subsets, no time window
cfitConfig.TYPE = java.lang.String.valueOf('evoked');
cfitConfig.NAME = java.lang.String.valueOf('Run02_lefthandmovementtovisualcue_raw_tsss_ecgClean_ave.fif');
cfitConfig.PATH = java.lang.String.valueOf('/MEG_data/test/megclinic_demo/100303/sss/Run02_lefthandmovementtovisualcue');
cfitConfig.FIT_INTERVAL = java.lang.String.valueOf('2');
cfitConfig.CH_SUBSET = 0;
cfitConfig.GLOBAL_SUBSET = 0;
cfitConfig.RAW_TIME_WIN = 0;
cfitConfig.EVOKED_TIME_WIN = 0;
cfitConfig.EVE_FILE = java.lang.String.valueOf('');
cfitConfig.EVE_NUM = java.lang.String.valueOf('');
cfitConfig.EVE_START = java.lang.String.valueOf('');
cfitConfig.EVE_END = java.lang.String.valueOf('');
cfitConfig.BASELINE = 1;
cfitConfig.BASE_START = java.lang.String.valueOf('-200');
cfitConfig.BASE_END = java.lang.String.valueOf('0');
cfitConfig.WIN_START = java.lang.String.valueOf('');
cfitConfig.WIN_END = java.lang.String.valueOf('');

process_xfit_input(mc)
