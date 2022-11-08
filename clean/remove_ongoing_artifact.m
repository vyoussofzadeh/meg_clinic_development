function remove_ongoing_artifact(mc, FileNames)
% remove_ongoing_artifact: create an SSP projection for ongoing artifacts
%
% USAGE:    remove_ongoing_artifact(mc, FileNames)
%
% INPUT:    mc = megclinic instance
%           FileNames = Filename structure
%
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009  Creation
% -------------------------------------------------------------------------

% -------------- SSP ------------------------------------------------------
% check to see if proj file already exists
checkfile = fullfile(FileNames.filelocation, FileNames.ogProjFileName);
projExists = exist(checkfile,'file');
if (projExists == 0)
    % create new ssp operators
    mc.setMessage(GUI.Config.M_MAKE_SSP);
    make_proj_operator(FileNames.filelocation, FileNames.filename, [], 'ONGOING');
    
    % find all _ongoing-proj.fif files
    projFile = dir(fullfile(FileNames.filelocation, ['*' char(ArtifactClean.CleanConfig.ONGOING_PROJ) '.fif']));
    % find the most recent
    [date,index] = max([projFile.datenum]);
    projFile = fullfile(FileNames.filelocation,projFile(index).name);

    % Rename this file if different than the convention
    if ~strcmp(projFile, fullfile(FileNames.filelocation, FileNames.ogProjFileName))
        movefile(projFile, fullfile(FileNames.filelocation, FileNames.ogProjFileName));
    end
else
    disp('ongoing SSP complete')
end

mc.setMessage(GUI.Config.M_DONE);