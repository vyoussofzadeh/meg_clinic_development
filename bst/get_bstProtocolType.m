function status = get_bstProtocolType()
% get_bstProtocolType: callback function from MEG-Clinic
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 15-DEC-2009    Creation
% -------------------------------------------------------------------------
status = 1;
config = GUI.Config;

options = [{'Create a new protocol per subject'} {'Create a new protocol for many subjects'} {'Select existing protocol'} ];
[selectedOption,okButton] = listdlg('Name', 'Create Protocol', 'PromptString', 'Select One:',...
                'SelectionMode','single','ListSize',[320 120], ...
                'ListString',options);
            
if okButton
    switch selectedOption
        case 1
            config.BST_PROTOCOL_TYPE = '1';    
            
        case 2
            prompt = {'Enter the name of protocol'};
            dlg_title = 'Protocol Name for Many Subjects';
            num_lines = 1;
            ops.Resize = 'on'; ops.WindowStyle = 'normal'; ops.Interpreter = 'none';
            answer = inputdlg(prompt,dlg_title,num_lines,{' '},'on');
            
            if isempty(answer)
                status = 0;
            else
                config.BST_PROTOCOL_TYPE = '2';
                config.BST_PROTOCOL_NAME = answer;
            end
            
        case 3
            % Get all protocols available in brainstorm
            protocolList = get_bstProtocolList;
            [selectedName,ok] = listdlg('Name', 'Existing Protocols', 'PromptString', 'Select One:',...
                'SelectionMode','single','ListSize',[320 160],...
                'ListString',protocolList);
            
            if ok
                config.BST_PROTOCOL_TYPE = '3';
                config.BST_PROTOCOL_NAME = protocolList(selectedName);
            else
                status = 0;
            end
    end
else
    status = 0;
end
