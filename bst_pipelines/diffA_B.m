% Script generated by Brainstorm v3.1 (30-May-2011).

FileNamesA = {...
    '/peterson_stephan/Run05_definition_naming_auditory_raw_sss_ecgClean_XtraClean_raw/results_average_110726_1525.mat'};
FileNamesB = {...
    '/peterson_stephan/Run05_definition_naming_auditory_raw_sss_ecgClean_XtraClean_raw/results_average_110726_1530.mat'};

% Process: Difference A-B
sFiles = bst_process(...
    'CallProcess', 'process_diff_ab', ...
    FileNamesA, FileNamesB, ...
    'source_abs', 0);
