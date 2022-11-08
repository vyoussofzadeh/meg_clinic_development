function protocolList = get_bstProtocolList()
% get_bstProtocolList: callback function from MEG-Clinic
%
% USAGE:    set(bstProtocols, 'ActionPerformedCallback', @get_bstProtocolList);
%           get_bstProtocolList()
%
% INPUT:    mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 15-DEC-2009    Creation
% EB 26-MAY-2010    Updates for callback
% -------------------------------------------------------------------------

% Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end

sProtocolInfo = bst_get('ProtocolsListInfo');
nProtocols = size(sProtocolInfo,2);
protocolList = java.util.ArrayList;
for n=1:nProtocols
    protocolList.add(sProtocolInfo(n).Comment);
end

config = BrainstormIO.BstConfig;
config.PROTOCOL_LIST = protocolList;
disp(config.PROTOCOL_LIST);
