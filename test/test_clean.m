% This script is for testing the cleaning functions of megclinic
% Start meg_clinic('gui')
% In the gui, select the raw sss file for cleaning 
%       _raw_sss.fif, _raw_defaultHead_sss.fif, _raw_cHPIsss.fif, raw_tsss.fif


type = 'ECG_ONLY';
%type = 'ONGOING_AND_ECG';
%type = 'ONGOING_ONLY';

delete('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_spont_raw_sss_ecgClean_raw.fif')
delete('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_spont_raw_sss_ecgClean_raw-eve.fif')
delete('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_spont_raw_sss_ecg-eve.fif')
delete('/MEG_data/test/megclinic_demo/100303/sss/run01_spont/run01_spont_raw_sss_ecg-proj.fif')

ecgConfig = ArtifactClean.CleanConfig;

switch type
    case 'ECG_ONLY'
        ecgConfig.INCLUDE_ECG = 1;
        ecgConfig.ECG_EVENTS = java.lang.String.valueOf('_ecg-eve');
        ecgConfig.ECG_PROJ = java.lang.String.valueOf('_ecg-proj');
        ecgConfig.ECG_TMIN = java.lang.String.valueOf('-0.08');
        ecgConfig.ECG_TMAX = java.lang.String.valueOf('0.08');
        ecgConfig.ECG_NMAG = java.lang.String.valueOf('1');
        ecgConfig.ECG_NGRAD = java.lang.String.valueOf('1');
        ecgConfig.ECG_AVETAG = java.lang.String.valueOf('_ave');
        ecgConfig.INCLUDE_ECG_FILTERING = 1;
        ecgConfig.ECG_HPFILTER = java.lang.String.valueOf('10');
        ecgConfig.ECG_LPFILTER = java.lang.String.valueOf('40');
        ecgConfig.CLEANTAG = java.lang.String.valueOf('_ecgClean');

        ecgConfig.INCLUDE_ONGOING = 0;
        
    case 'ONGOING_AND_ECG'
        ecgConfig.INCLUDE_ECG = 1;
        ecgConfig.ECG_EVENTS = java.lang.String.valueOf('_ecg-eve');
        ecgConfig.ECG_PROJ = java.lang.String.valueOf('_ecg-proj');
        ecgConfig.ECG_TMIN = java.lang.String.valueOf('-0.08');
        ecgConfig.ECG_TMAX = java.lang.String.valueOf('0.08');
        ecgConfig.ECG_NMAG = java.lang.String.valueOf('1');
        ecgConfig.ECG_NGRAD = java.lang.String.valueOf('1');
        ecgConfig.ECG_AVETAG = java.lang.String.valueOf('_ave');
        ecgConfig.INCLUDE_ECG_FILTERING = 1;
        ecgConfig.ECG_HPFILTER = java.lang.String.valueOf('10');
        ecgConfig.ECG_LPFILTER = java.lang.String.valueOf('40');

        ecgConfig.INCLUDE_ONGOING = 1;
        ecgConfig.ONGOING_NMAG = java.lang.String.valueOf('3');
        ecgConfig.ONGOING_NGRAD = java.lang.String.valueOf('3');
        ecgConfig.ONGOING_PROJ = java.lang.String.valueOf('_ongoing-proj');
        ecgConfig.INCLUDE_OG_FILTERING = 1;
        ecgConfig.OG_HPFILTER = java.lang.String.valueOf('1.5');
        ecgConfig.OG_LPFILTER = java.lang.String.valueOf('5');

        ecgConfig.CLEANTAG = java.lang.String.valueOf('_xtraClean');

    case 'ONGOING_ONLY'
        ecgConfig.INCLUDE_ECG = 1;

        ecgConfig.INCLUDE_ONGOING = 1;
        ecgConfig.ONGOING_NMAG = java.lang.String.valueOf('3');
        ecgConfig.ONGOING_NGRAD = java.lang.String.valueOf('3');
        ecgConfig.ONGOING_PROJ = java.lang.String.valueOf('_ongoing-proj');
        ecgConfig.INCLUDE_OG_FILTERING = 1;
        ecgConfig.OG_HPFILTER = java.lang.String.valueOf('1.5');
        ecgConfig.OG_LPFILTER = java.lang.String.valueOf('5');

        ecgConfig.CLEANTAG = java.lang.String.valueOf('_ongoingClean');
end

% Run the function
process_auto_clean(mc);
