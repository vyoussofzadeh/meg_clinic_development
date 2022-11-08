function brainstorm_importMeg(selectedPaths, mc)
% brainstorm_importMeg: Import MEG recordings into brainstorm
%
% USAGE:    brainstorm_importMeg(selectedPaths, mc)
%
% INPUT:
%           selectedPaths = ArrayList<String> of all selected paths from the
%           database tree
%           mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 24-MAY-2010    Creation
% -------------------------------------------------------------------------

% Get the message area
messages = GUI.CallbackInterface.messageTextArea;

for i=1:selectedPaths.size
    % -----Get current study name
    selectedFile = char(selectedPaths.get(i-1));
    [path, fileName, ext, vrsn] = fileparts(selectedFile);
    %fif file - find the DataFile
    sProtocol = bst_get('ProtocolInfo');
    studyDir = sProtocol.STUDIES;
    subjectName = char(mc.getInfo(GUI.Config.I_SUBJECT));
    [sSubject, iSubject] = bst_get('Subject',subjectName);
    subjectName = sSubject.Name;
    currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
    [sStudy, iStudy] = bst_get('Study', currentStudyName);

    % -----Check for imported file
    if ~BrainstormIO.BstConfig.IMPORTRAW
        messages.setText(['Brainstorm - Import Evoked: ' fileName])
        OPTIONS.ImportRaw = 0;
        OPTIONS.EventRecMaps = 0;
        OPTIONS.EventAve = 0;
        OPTIONS.BkgrndSources = 0;
        OPTIONS.SpectralMaps = 0;
        OPTIONS.UseAnnotFile = 0;
        import_MEG_to_bst(selectedFile, iSubject, currentStudyName, OPTIONS);
        mc.setWorkflowVariable(GUI.WorkflowConfig.BSTMEG, fullfile(studyDir, subjectName, fileName), false);
    else
        % -----Import 2 second chuncks
        if BrainstormIO.BstConfig.SPECTRAL_MAPS || BrainstormIO.BstConfig.BKGRND_SOURCES
            dataIndices = [];
            if ~isempty(sStudy)
                pat='Raw';
                x=regexp({sStudy.Data.Comment}, pat);
                c=cellfun(@isempty, x);
                dataIndices = find(c==0);
            end

            if isempty(sStudy) || isempty(dataIndices)
                % -----Import Selected File (with user options)
                messages.setText(['Brainstorm - Import Raw: ' fileName])
                OPTIONS.ImportRaw = 1;
                OPTIONS.EventRecMaps = 0;
                OPTIONS.EventAve = 0;
                OPTIONS.BkgrndSources = BrainstormIO.BstConfig.BKGRND_SOURCES;
                OPTIONS.SpectralMaps = BrainstormIO.BstConfig.SPECTRAL_MAPS;
                OPTIONS.UseAnnotFile = 0;
                import_MEG_to_bst(selectedFile, iSubject, currentStudyName, OPTIONS);
                mc.setWorkflowVariable(GUI.WorkflowConfig.BSTMEG, fullfile(studyDir, subjectName, fileName), false);
            end
        end

        [sStudy, iStudy] = bst_get('Study', currentStudyName);
        
        % -----Import raw chunks corresponding to events
        if BrainstormIO.BstConfig.EVENT_LATENCY || BrainstormIO.BstConfig.EVENTS_AVE
            dataIndices = [];

            if isempty(sStudy) || isempty(dataIndices)
                % -----Import Selected File (with user options)
                messages.setText(['Brainstorm - Import Events: ' fileName])
                OPTIONS.ImportRaw = 1;
                OPTIONS.EventRecMaps = BrainstormIO.BstConfig.EVENT_LATENCY;
                OPTIONS.EventAve = BrainstormIO.BstConfig.EVENTS_AVE;
                OPTIONS.BkgrndSources = 0;
                OPTIONS.SpectralMaps = 0;
                OPTIONS.UseAnnotFile = BrainstormIO.BstConfig.USEANNOT;
                import_MEG_to_bst(selectedFile, iSubject, currentStudyName, OPTIONS);
            end
        end
    end
end
