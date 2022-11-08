function process_configure_bst(type)
% process_configure_bst: callback for MEG-Clinic
%
% USAGE:    process_configure_bst(type)
%
% INPUT:    type = 'gui', 'default' original MEG raw files
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 2010    Creation
% -------------------------------------------------------------------------

% Brainstorm datapath defined in setup_configuration.xml
% This should be /MEG_data for creating protocols per subject
% and should be /MEG_data/brainstorm_db for creating protocols for many
% subjects
bstDataPath = char(GUI.DataSet.bstDataPath);
projectName = char(GUI.DataSet.project);
subjectName = char(GUI.DataSet.subject);
config = GUI.Config;

% Button press from MEG-Clinic gui
if strcmp(type, 'gui')
%     protocolList = get_bstProtocolList;
%     bstConfig = GUI.BstConfig(protocolList);
%     setVisible(bstConfig, 1);
%     uiwait(bstConfig.getContentPane())
    ok = get_bstProtocolType();
    if ~ok
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, 'No protocol type selected, default to type 1');
        config.BST_PROTOCOL_TYPE = '1';
    end
    % Define configuration for selected protocol type
    switch (char(GUI.Config.BST_PROTOCOL_TYPE))
        case '1'
            config.BST_PROTOCOL_NAME = [projectName '_' subjectName];
            % Brainstorm datapath is updated here to
            % /MEG_data/<project>/<subject>/brainstorm_db
            config.BST_DB_DIR = fullfile(bstDataPath, projectName, subjectName, 'brainstorm_db');

        case '2'        
            config.BST_DB_DIR = fullfile(bstDataPath, 'brainstorm_db');

        case '3'
            config.BST_DB_DIR = fullfile(bstDataPath, 'brainstorm_db');
    end
end

% Set configuration for default protocol type (one protocol per subject)
if strcmp(type, 'default')
    config.BST_PROTOCOL_TYPE = '1';    
    config.BST_PROTOCOL_NAME = [projectName '_' subjectName];
    % Brainstorm datapath is updated here to
    % /MEG_data/<project>/<subject>/brainstorm_db
    config.BST_DB_DIR = fullfile(bstDataPath, projectName, subjectName, 'brainstorm_db');
end