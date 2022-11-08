function process_batch_clean(varargin)
% process_batch_clean: callback function from MEG-Clinic, Remove Artifacts 
% configure menu, Clean All button
%
% USAGE:    set(cleanBatchButton, 'ActionPerformedCallback', {@process_batch_clean, mc})
%           process_batch_clean(mc)
%
% INPUT:    mc = MEG-Clinic instance
%
% Author:   Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009    Creation
% EB 26-MAY-2010    Updates for callback
% -------------------------------------------------------------------------

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

% ------------ Process all runs ---------------------------------------
% Get the number of tree nodes
numRuns = mc.getNumTreeNodes();
% Start the progress bar
progress = GUI.MegclinicProgressBar(0, numRuns, 'Batch Clean Progress','Cleaning in progress...');
config = GUI.Config;
config.SHOW_ERROR_DIALOG = 0;

% For all nodes in the tree
for n=1:numRuns-1 
    if mc.runNextClean(n)
        % Find the next node in the tree that has a raw_sss.fif file and
        % make that file the selected node        
        progress.setValue(n);
        
        % ----- ECG Clean 
        disp(['Processing ' ... 
            char(mc.getInfo(GUI.Config.I_SELECTEDFILE)) ... 
            '...']); 

        [FileNames, mask, stimSource] = process_auto_clean(mc);

        if ~isempty(FileNames)
            % ----- Clean ave 
            wf = GUI.DataSet.currentWorkflow;
            ave = char(wf.getName(GUI.WorkflowConfig.AVE));

            % check for existing clean raw file
            cleanExist = exist(fullfile(FileNames.filelocation, FileNames.cleanFileName), 'file');

            if ~strcmp(ave,'') % Functional data present
                if cleanExist
                    % Generate a clean evoked file
                    mc.setMessage(GUI.Config.M_MAKE_CLEAN_AVE);
                    generate_evoked_clean(FileNames, mask, stimSource);
                else
                    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, ['The cleaned file ' fullfile(FileNames.filelocation, FileNames.cleanFileName) ' does not exist.  The average cleaned file will not be created.']);
                end
            else
                disp ('Functional Data not present in this recording')
            end
            mc.refreshSelectedTreeNode();
            mc.refreshSelectedWorkflow(mc.getCurrentWorkflow());
            disp('Done')
        end
    end
    % Clear variables and get next run
    clear FileNames mask stimSource
end
% Close the progress bar
progress.close();
config.SHOW_ERROR_DIALOG = 1;
