%% ===== START BRAINSTORM =====
% Add brainstorm.m path to the path
addpath('/opt/brainstorm3');
% If brainstorm is not running yet: Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm start
end

% Add other paths of interest
addpath('/MEG_data/megclinic/tools')
addpath('/MEG_data/megclinic/bst')

%% Populate file list

%% main ADN file list

datafilelist(1).recordings = {'/MEG_data/epilepsy/peterson_stephan/110204/sss/Run05_definition_naming_auditory/Run05_definition_naming_auditory_raw_sss_ecgClean_XtraClean_raw.fif'};
datafilelist(2).recordings = {'/MEG_data/epilepsy/tremble_hannah/110113/sss/run11_definition_naming/run11_definition_naming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/tremble_hannah/110113/sss/Run_definition_naming/Run_definition_naming_raw_sss_xtraClean_raw.fif'};
datafilelist(3).recordings = {'/MEG_data/epilepsy/childs_donna/101228/sss/Run09_auditory_naming/Run09_auditory_naming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/childs_donna/101228/sss/Run10_auditory_naming/Run10_auditory_naming_raw_sss_xtraClean_raw.fif'};
datafilelist(4).recordings = {'/MEG_data/epilepsy/gosse_jay/101223/sss/Run07_auditorynaming/Run07_auditorynaming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/gosse_jay/101223/sss/Run09_auditorynaming/Run09_auditorynaming_raw_sss_xtraClean_raw.fif'};
datafilelist(5).recordings = {'/MEG_data/epilepsy/marie_carissa/110105/sss/Run10_definition_naming/Run10_definition_naming_raw_sss_XtraClean_raw.fif', ...
'/MEG_data/epilepsy/marie_carissa/110105/sss/run11_definition_naming/run11_definition_naming_raw_sss_XtraClean_raw.fif'};
datafilelist(6).recordings = {'/MEG_data/epilepsy/granata_carl/110421/sss/Run06_auditoryN_naming/Run06_auditoryN_naming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/granata_carl/110421/sss/Run07_auditory_naming/Run07_auditory_naming_raw_sss_XtraClean_raw.fif'};
datafilelist(7).recordings = {'/MEG_data/epilepsy/zeller_richard/110719/sss/Run03_definition_naming/Run03_definition_naming_raw_defaultHead_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/zeller_richard/110719/sss/Run04_definition_naming/Run04_definition_naming_raw_defaultHead_sss_xtraClean_raw.fif'};
datafilelist(8).recordings = {'/MEG_data/epilepsy/radtke_michael/110720/sss/Run04_defnaming/Run04_defnaming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/radtke_michael/110720/sss/Run05_defnaming/Run05_defnaming_raw_sss_xtraClean_raw.fif'};
datafilelist(9).recordings = {'/MEG_data/epilepsy/ferentchak_kevin/110617/sss/Run04_auditory_naming/Run04_auditory_naming_raw_sss_XtraClean_raw.fif', ...
'/MEG_data/epilepsy/ferentchak_kevin/110617/sss/Run05_auditory_naming/Run05_auditory_naming_raw_sss_XtraClean_raw.fif'};
datafilelist(10).recordings = {'/MEG_data/epilepsy/drechsler_leddy/110617/sss/Run04_autditorynaming/Run04_autditorynaming_raw_sss_eogClean_raw.fif', ...
'/MEG_data/epilepsy/drechsler_leddy/110617/sss/Run05_auditory_naming/Run05_auditory_naming_raw_sss_eogClean_raw.fif'};
datafilelist(11).recordings = {'/MEG_data/epilepsy/coleman_savannah/110426/sss/Run09_auditory_definition_naming/Run09_auditory_definition_naming_raw_sss_ecgClean_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/coleman_savannah/110426/sss/Run10_auditory_definition_naming/Run10_auditory_definition_naming_raw_sss_ecgClean__XtraClean_raw.fif'};
datafilelist(12).recordings = {'/MEG_data/epilepsy/schneider_michael/110104/sss/Run08_definition_naming/Run08_definition_naming_raw_sss_xtra_Clean_raw.fif', ...
'/MEG_data/epilepsy/schneider_michael/110104/sss/Run09_definition_naming/Run09_definition_naming_raw_sss_ongoingClean_XtraClean_raw.fif'};
datafilelist(13).recordings = {'/MEG_data/epilepsy/scheuers_iric/100317/sss/Run10_auditorydefinitionnaming/Run10_auditorydefinitionnaming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/scheuers_iric/100317/sss/Run11_auditorydefinitionnaming/Run11_auditorydefinitionnaming_raw_sss_xtraClean_raw.fif'};
datafilelist(14).recordings = {'/MEG_data/epilepsy/templin_clayton/101118/sss/Run10_auditorynaming/Run10_auditorynaming_raw_sss_ecgClean_raw.fif'};
datafilelist(15).recordings = {'/MEG_data/epilepsy/sosinski_abigail/100614/sss/Run10_definitionnaming/Run10_definitionnaming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/sosinski_abigail/100614/sss/Run11_definitionnaming/Run11_definitionnaming_raw_sss_xtraClean_raw.fif'};
datafilelist(16).recordings = {'/MEG_data/epilepsy/greene_alexandra/100603/sss/Run07_definition_naming/Run07_definition_naming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/greene_alexandra/100603/sss/Run08_definition_naming/Run08_definition_naming_raw_sss_xtraClean_raw.fif'};
datafilelist(17).recordings = {'/MEG_data/epilepsy/villnow_joel/100119/sss/run05_defnaming_language/run05_defnaming_language_raw_defaultHead_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/villnow_joel/100119/sss/run06_refnaming_language/run06_refnaming_language_raw_defaultHead_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/villnow_joel/100119/sss/run07_refnaming_language/run07_refnaming_language_raw_defaultHead_sss_xtraClean_raw.fif'};
datafilelist(18).recordings = {'/MEG_data/epilepsy/lewis_rickey/101202/sss/Run10_definition_naming/Run10_definition_naming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/lewis_rickey/101202/sss/Run11_definition_naming/Run11_definition_naming_raw_sss_xtraClean_raw.fif'};
datafilelist(19).recordings = {'/MEG_data/epilepsy/bozeman_emily/091207/sss/run03_language_aud_naming/run03_language_aud_naming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/bozeman_emily/091207/sss/Run05_language_aud_naming/Run05_language_aud_naming_raw_sss_xtraClean_raw.fif', ...
'/MEG_data/epilepsy/bozeman_emily/091207/sss/Run06_language_aud_naming/Run06_language_aud_naming_raw_sss_xtraClean_raw.fif'};

LI = MEGLImaker(datafilelist(6));


%% tumor patient list

%WN
% '/MEG_data/epilepsy/washi_nissan/101208/sss/Run08_auditorydefinitionnmaiming/Run08_auditorydefinitionnmaiming_raw_sss_xtraClean_raw.fif'
% '/MEG_data/epilepsywashi_nissan/101208/sss/Run09_auditorydefinitionnaming/Run09_auditorydefinitionnaming_raw_sss_xtraClean_raw.fif'
% '/MEG_data/epilepsy/washi_nissan/101208/sss/Run10_auditorydefinitionnaming/Run10_auditorydefinitionnaming_raw_sss_xtraClean_raw.fif'

%JW
% '/MEG_data/epilepsy/white_jonathan/101203/sss/Run08_auddefinitionnaming/Run08_auddefinitionnaming_raw_defaultHead_sss_xtraClean_raw.fif'
% '/MEG_data/epilepsy/white_jonathan/101203/sss/Run09_auddefinitionnaming/Run09_auddefinitionnaming_raw_defaultHead_sss_xtraClean_raw.fif'


%DH
%'/MEG_data/epilepsy/hanson_danny/110106/sss/Run10_definition_naming/Run10_definition_naming_raw_sss_no_unlocking_xtraClean_raw.fif'
% '/MEG_data/epilepsy/hanson_danny/110106/sss/Run11_definition_naming/Run11_definition_naming_raw_sss_xtraClean_raw.fif'

%% fMRI datafilelist (n=2)

%SP
%'/MEG_data/epilepsy/peterson_stephan/110204/sss/Run05_definition_naming_auditory/Run05_definition_naming_auditory_raw_sss_ecgClean_XtraClean_raw.fif'

%HT
%'/MEG_data/epilepsy/tremble_hannah/110113/sss/run11_definition_naming/run11_definition_naming_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/tremble_hannah/110113/sss/Run_definition_naming/Run_de
%finition_naming_raw_sss_xtraClean_raw.fif'

%% no good subjects

%ajoyce - old tasks

%AG - 3 events in "ADN" paradigm
%'/MEG_data/epilepsy/greene_alexandra/100603/sss/Run07_definition_naming/Run07_definition_naming_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/greene_alexandra/100603/sss/Run08_definition_naming/Run08_definition_naming_raw_sss_xtraClean_raw.fif'
% These files have three events??

% '/MEG_data/epilepsy/oehler_jason/091105/sss/run05_language/run05_language_raw_sss_xtraClean_raw.fif', ...
% '/MEG_data/epilepsy/oehler_jason/091105/sss/run06_language/run06_language
% _raw_sss_xtraClean_raw.fif', ...

%JO 3 events in "ADN" paradigm
%'/MEG_data/epilepsy/oehler_jason/091105/sss/run04_language/run04_language_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/oehler_jason/091105/sss/run05_language/run05_language_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/oehler_jason/091105/sss/run06_language/run06_language_
%raw_sss_xtraClean_raw.fif'
%JO
%'/MEG_data/epilepsy/oehler_jason/091105/sss/run04_language/run04_language_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/oehler_jason/091105/sss/run05_language/run05_language_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/oehler_jason/091105/sss/run06_language/run06_language_
%raw_sss_xtraClean_raw.fif'

%JV 3 events in "ADN" paradigm
%'/MEG_data/epilepsy/villnow_joel/100119/sss/run05_defnaming_language/run05_defnaming_language_raw_defaultHead_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/villnow_joel/100119/sss/run06_refnaming_language/run06_refnaming_language_raw_defaultHead_sss_xtraClean_raw.fif'
% need the xtra clean for this run '/MEG_data/epilepsy/villnow_joel/100119/sss/run07_refnaming_language/

%RL 3 events in "ADN" paradigm
%'/MEG_data/epilepsy/lewis_rickey/101202/sss/Run10_definition_naming/Run10_definition_naming_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/lewis_rickey/101202/sss/Run11_definition_naming/Run11_
%definition_naming_raw_sss_xtraClean_raw.fif'

%PL - head transformation issue
%'/MEG_data/epilepsy/laviollette_peter/110224/sss/run03_auditoryDefinitionNaming/run03_auditoryDefinitionNaming_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/laviollette_peter/110224/sss/run04_auditoryDefinitionNaming/run04_auditoryDefinitionNaming_raw_sss_xtraClean_raw.fif'

%3 events in "ADN" paradigm
%3 events in "ADN" paradigm


%--------------------------------------------------------------------------------------------------------------------------
%Word Reading and Picture Naming for later(?)
%'/MEG_data/epilepsy/templin_clayton/101118/sss/Run10_auditorynaming/Run06_
%languagehouston_raw_sss_xtraClean_raw.fif'
%'/MEG_data/epilepsy/templin_clayton/101118/sss/Run07_languagehouston/Run07
%_languagehouston_raw_sss_xtraClean_raw.fif'
