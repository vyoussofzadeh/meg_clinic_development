function selectedStudies = mc_bst_import_avgepochs(aveFiles)
% mc_bst_import_avgepochs: imports the functional paradigm average epochs
%
% USAGE:    selectedStudies = mc_bst_import_avgepochs(aveFiles)
%
% INPUT:    aveFiles = original MEG average files
%
% OUTPUT:   selectedStudies = study indices of the new studies created here
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 12-JULY-2011    Creation
% -------------------------------------------------------------------------
selectedStudies = [];
for f = 1:length(aveFiles)

 % -----Get corresponding "study" name
    selectedFile = aveFiles{f};
    [path, fileName] = fileparts(selectedFile);
    sProtocol = bst_get('ProtocolInfo');
    studyDir = sProtocol.STUDIES;
    subjectName = char(GUI.DataSet.subject);
    [sSubject, iSubject] = bst_get('Subject',subjectName);
    subjectName = sSubject.Name;
    currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
    % Check for raw segments already imported
    [sStudy, iStudy]=bst_get('Study', currentStudyName);   

    % Open FIF file
    sFile = in_fopen_fif(selectedFile, 1, 1);
    
    % Get default structure for configuring import
    ImportOptions = db_template('ImportOptions');
    
    % -----Import events
    ImportOptions.ImportMode = 'Epoch';
    ImportOptions.GetAllEpochs = 1;
    ImportOptions.Events = sFile.epochs;
    ImportOptions.UseSsp = 1; 
    ImportOptions.RemoveBaseline = 'time';
    ImportOptions.BaselineRange  = [-0.5 0];
    ImportOptions.CreateConditions = 0;
    ImportOptions.AutoAnswer = 1;
    ImportOptions.AlignSensors = 2;
    
    % Import recordings
    import_data(sFile, 'FIF', iStudy, iSubject, ImportOptions);
    [sStudy, iStudy]=bst_get('Study', currentStudyName);   
    selectedStudies = [selectedStudies iStudy];
end

    
   