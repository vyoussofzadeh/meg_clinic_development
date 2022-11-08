function mriFile = mc_bst_import_mriandsurfaces(subjectName, mriDir)
% mc_bst_import_mriandsurfaces: import MRI and surfaces into brainstorm database 
%
% USAGE:    mc_bst_import_mriandsurfaces(subjectName, mriDir)           
% INPUT:    subjectName = name of record (lastname_firstname)
%           mriDir = full path to the subject's MRI database folder
%           (/MEG_data/MRI_database/<project>/LAST_First)
% OUTPUT:   mriFile = name of the MRI file to import
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 21-MAY-2010    Creation
% EB 7-May-2013     Update to use BST process scripts
% -------------------------------------------------------------------------

%% Define parameters
[~, iSubject] = bst_get('Subject' ,subjectName);

if isempty(mriDir)
    %Open a dialog to set the MRIDIR
    mriDir = uigetdir([], 'Select the MRI Directory');
end

nVertices = 15000;
isInteractive = 1;

%% Import call to brainstorm
if ~isempty(file_find(mriDir, '*.ima')) || ~isempty(file_find(mriDir, '*.nii'))
    % Import BrainVISA folder
    import_anatomy_bv(iSubject, mriDir, nVertices, isInteractive);

elseif file_find(mriDir, '*.mgz')
    % Import FreeSurfer folder
    import_anatomy_fs(iSubject, mriDir, nVertices, isInteractive);

else
    javax.swing.JOptionPane.showMessageDialog([],'Unrecognized MRI file. Please select a BrainsVisa or Freesurfer folder',...
        'Import MRI File Error', javax.swing.JOptionPane.WARNING_MESSAGE);
    return
end
end