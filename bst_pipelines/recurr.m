% Script generated by Brainstorm v3.1 (30-May-2011).

FileNamesA = {...
    'link|sample_set2/run03_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0955.mat|sample_set2/run03_spont_raw_sss_xtraClean_raw/data_Event__2000_trial001.mat', ...
    'link|sample_set2/run03_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0955.mat|sample_set2/run03_spont_raw_sss_xtraClean_raw/data_Event__2000_trial002.mat', ...
    'link|sample_set2/run03_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0955.mat|sample_set2/run03_spont_raw_sss_xtraClean_raw/data_Event__2000_trial003.mat', ...
    'link|sample_set2/run03_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0955.mat|sample_set2/run03_spont_raw_sss_xtraClean_raw/data_Event__2000_trial004.mat', ...
    'link|sample_set2/run03_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0955.mat|sample_set2/run03_spont_raw_sss_xtraClean_raw/data_Event__2000_trial005.mat', ...
    'link|sample_set2/run03_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0955.mat|sample_set2/run03_spont_raw_sss_xtraClean_raw/data_Event__2000_trial006.mat', ...
    'link|sample_set2/run04_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0957.mat|sample_set2/run04_spont_raw_sss_xtraClean_raw/data_Event__2000_trial001.mat', ...
    'link|sample_set2/run04_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0957.mat|sample_set2/run04_spont_raw_sss_xtraClean_raw/data_Event__2000_trial002.mat', ...
    'link|sample_set2/run04_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0957.mat|sample_set2/run04_spont_raw_sss_xtraClean_raw/data_Event__2000_trial003.mat', ...
    'link|sample_set2/run04_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0957.mat|sample_set2/run04_spont_raw_sss_xtraClean_raw/data_Event__2000_trial004.mat', ...
    'link|sample_set2/run04_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0957.mat|sample_set2/run04_spont_raw_sss_xtraClean_raw/data_Event__2000_trial005.mat', ...
    'link|sample_set2/run04_spont_raw_sss_xtraClean_raw/results_wMNE_MEG_KERNEL_110706_0957.mat|sample_set2/run04_spont_raw_sss_xtraClean_raw/data_Event__2000_trial006.mat'};
FileNamesB = [];

% Process: [Experimental] Recurrence maps of activations
sFiles = bst_process(...
    'CallProcess', 'process_recurrence2', ...
    FileNamesA, FileNamesB, ...
    'timewindow', [-0.3, 0.1], ...
    'bandPass1', 5, ...
    'bandPass2', 40);

