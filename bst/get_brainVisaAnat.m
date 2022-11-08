function [mriFile, surfaces] = get_brainVisaAnat(mriDir, mriFile)
% get_brainVisaAnat: searches for anatomy files in the BrainVisa format 
%
% USAGE:    [mriFile, surfaces] = get_brainVisaAnat(mriDir, mriFile)
%           [mriFile, surfaces] = get_brainVisaAnat(mriDir, [])
%           
% INPUT:    mriDir = directory of subject's anatomy
%           mriFile = name of the mri file for the subject
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 12-JULY-2010 Creation
% -------------------------------------------------------------------------  
%% MRI
if isempty(mriFile)
    % Find the MRI path
    [pathstr,mriSubjectName] = fileparts(mriDir);
    if strcmp(mriSubjectName, 'DICOM') || strcmp(mriSubjectName, 't1mri')
        mriDir = pathstr;
        [pathstr,mriSubjectName] = fileparts(mriDir);
    end

    % Look for .ima file
    mriFile = fullfile(mriDir, '/t1mri/default_acquisition', [mriSubjectName '.ima']);
    if ~exist(mriFile, 'file')
        % Look for .nii file
        mriFile = fullfile(mriDir, '/t1mri/default_acquisition', [mriSubjectName '.nii']);
        if ~exist(mriFile, 'file')
            % No match, return
            mriFile = [];
            surfaces = [];
            return
        end
    end
end

%% Surfaces
scalp = [];
Lh = [];
Rh = [];
Lw = [];
Rw = [];
innerSkull = [];

% Find the mesh files
[Files, Bytes, Names] = dirr(mriDir, '_head.mesh', 'name');
if isempty(Names)
     % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select the *_head.mesh file');
    curDir = java.io.File(mriDir);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
       Names{1} = char(fc.getSelectedFile());
    else
       return
    end
end
temp = Names{1};
[mesh_dir, sName] = fileparts(temp);
index = strfind(sName, '_head');
% Subject name
sName = sName(1:index-1);
% Mesh files

scalp = fullfile(mesh_dir, [sName '_head.mesh']); % outer skin
if ~exist(scalp,'file')
     % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select the scalp mesh file');
    curDir = java.io.File(mriDir);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
       scalp = char(fc.getSelectedFile());
    else
       scalp = [];
    end
end
Lh = fullfile(mesh_dir, [sName '_Lhemi.mesh']);
Rh = fullfile(mesh_dir, [sName '_Rhemi.mesh']);
if ~exist(Lh, 'file') || ~exist(Rh, 'file')
    % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select the 2 cortical surface files');
    fc.setMultiSelectionEnabled(1);
    curDir = java.io.File(mesh_dir);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
        selFiles = fc.getSelectedFiles();
        file = char(selFiles(1));
        if strfind(lower(file), 'lh')
            Lh = file;
            Rh = char(selFiles(2));
        else
            Lh = char(selFiles(2));
            Rh = file;
        end

        % redefine the path for the surfaces
        [mesh_dir] = fileparts(Lh);
    end
end
Lw = fullfile(mesh_dir, [sName '_Lwhite.mesh']);
Rw = fullfile(mesh_dir, [sName '_Rwhite.mesh']);
if ~exist(Lw, 'file') || ~exist(Rw, 'file')
    % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select the 2 white matter surface files');
    fc.setMultiSelectionEnabled(1);
    curDir = java.io.File(mesh_dir);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
        selFiles = fc.getSelectedFiles();
        file = char(selFiles(1));
        if strfind(lower(file), 'lw')
            Lw = file;
            Rw = char(selFiles(2));
        else
            Lw = char(selFiles(2));
            Rw = file;
        end
    end
end
% No inner skull for brainVisa...
innerSkull = [];

surfaces = {scalp, Lh, Rh, Lw, Rw, innerSkull};

end