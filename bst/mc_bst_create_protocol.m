function mc_bst_create_protocol()
% mc_bst_create_protocol: uses brainstorm scripts to create a new protocol
%
% USAGE:    mc_bst_create_protocol()
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 2010    Creation (adapted from brainstorm3 scripts)
% -------------------------------------------------------------------------

%% ===== CREATE PROTOCOL =====
% Get default structure for protocol description
sProtocol = db_template('ProtocolInfo');
bstDbDir = char(BrainstormIO.BstConfig.BST_DB_DIR);

sProtocol.Comment  = char(BrainstormIO.BstConfig.BST_PROTOCOL_NAME);
sProtocol.SUBJECTS = fullfile(bstDbDir, 'anat');
sProtocol.STUDIES  = fullfile(bstDbDir, 'data');

% Create the Protocol in Brainstorm database
iProtocol = db_edit_protocol('create', sProtocol);
% If an error occured in protocol creation (protocol already exists, impossible to create folders...)
if (iProtocol <= 0)
    error('Could not create protocol.');
end

% Set this protocol as current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);
  