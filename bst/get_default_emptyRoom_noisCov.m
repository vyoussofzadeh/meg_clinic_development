function NoiseCovMat = get_default_emptyRoom_noisCov(type)

global GlobalData
% -----Save indice of current protocol
curProtocol = bst_get('iProtocol');

% -----Get empty room protocol
sProtocolInfo = GlobalData.DataBase.ProtocolInfo;
nProtocols = length(sProtocolInfo);
iProtocol = 0;
for n=1:nProtocols
    if strcmp(sProtocolInfo(n).Comment, 'default_empty_room')
        iProtocol = n;
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        break;
    end
end
emptyRoomBst = '/MEG_data/empty_room/empty_room/brainstorm_db';
if ~iProtocol && ~exist(emptyRoomBst,'dir')
    % no protocol exists and no default empty room bst exists
    emptyRoomNoiseCov = java_getfile('open', ...
        'Select default noise covarience matrix',GUI.DataSet.megDataPath, ...
        'single', 'files', ...
        {{'.mat'},{'Brainstorm (noisecov*.mat)'}, 'BST'}, 1);
    NoiseCovMat = import_noisecov([], emptyRoomNoiseCov);
    NoiseCovMat = NoiseCovMat.NoiseCov;
    return;
elseif ~iProtocol
    % Create a protocol for this default empty room
    % Get default structure for protocol description
    sProtocol = db_template('ProtocolInfo');
    sProtocol.Comment  = 'default_empty_room';
    sProtocol.SUBJECTS = fullfile(emptyRoomBst, 'anat');
    sProtocol.STUDIES  = fullfile(emptyRoomBst, 'data');

    % Create the Protocol in Brainstorm database
    iProtocol = db_edit_protocol('create', sProtocol);
    % If an error occured in protocol creation (protocol already exists, impossible to create folders...)
    if (iProtocol <= 0)
        error('Could not create protocol.');
    end
end

% Set this protocol as current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);
% Reload the subject in the database (in case it were changed outside the
% current users session
db_load_subjects();
db_load_studies();

% -----Get the desired position file
if strcmp(type, 'supine')
    fileName = 'empty_room_supine_raw_sss';
elseif strcmp(type, 'upright')
    fileName = 'empty_room_upright_raw_sss';
end

emptyRoomStudyDir = sProtocolInfo(iProtocol).STUDIES;
emptyRoomStudyName = fullfile(emptyRoomStudyDir, 'empty_room', fileName, 'brainstormstudy.mat');
[sStudy, iStudy] = bst_get('Study', emptyRoomStudyName);

% -----Import the noise covariance matrix from the empty room protocol
NoiseCovFile = fullfile(emptyRoomStudyDir, sStudy.NoiseCov.FileName);
NoiseCovMat = import_noisecov([], NoiseCovFile);
NoiseCovMat = NoiseCovMat.NoiseCov;

% -----Set protocol back to previous protocol
gui_brainstorm('SetCurrentProtocol', curProtocol);