function [emptyRoomStudyDir, emptyRoomStudyName] = get_default_emptyRoomStudy(type)

sProtocolInfo = bst_get('ProtocolsListInfo');
nProtocols = length(sProtocolInfo);
iProtocol = 0;
for n=1:nProtocols
    if strcmp(sProtocolInfo(n).Comment, 'epilepsy_empty_room')
        iProtocol = n;
        break;
    end
end

if strcmp(type, 'supine')
    fileName = 'empty_room_supine_raw_sss';
elseif strcmp(type, 'upright')
    fileName = 'empty_room_upright_raw_sss';
end

emptyRoomStudyDir = sProtocolInfo(iProtocol).STUDIES;
emptyRoomStudyName = fullfile(emptyRoomStudyDir, 'empty_room', fileName, 'brainstormstudy.mat');
