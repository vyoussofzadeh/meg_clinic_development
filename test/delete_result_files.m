function delete_result_files(type)
% This will delete files that have been created by megclinic
% It can be used during testing
% Options:

% type = 'ALL';
% type = 'CLEAN';
% type = 'XFIT';

global mc
wf = mc.getCurrentWorkflow();
path = char(wf.getName(GUI.WorkflowConfig.RUNDIR));

switch type
    case 'CLEAN'
        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.ECGEVE)));
        if exist(temp,'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.ECGPROJ)));
        if exist(temp, 'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.ECGCLEAN)));
        if exist(temp, 'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.ARTEVE)));
        if exist(temp, 'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.ARTPROJ)));
        if exist(temp, 'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.ARTCLEAN)));
        if exist(temp, 'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.AVEDESC)));
        if exist(temp, 'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.AVECLEAN)));
        if exist(temp, 'file')
            delete(temp);
        end

        temp = fullfile(path, char(wf.getName(GUI.WorkflowConfig.XML)));
        if exist(temp, 'file')
            delete(temp);
        end

    case 'ALL'
        if exist(path, 'dir')
            rmdir(path, 's');
        end

    case 'XFIT'
        temp = fullfile(path,'xfit');
        if exist(temp, 'dir')
            rmdir(temp, 's');
        end
end