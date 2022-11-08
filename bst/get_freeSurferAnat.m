function [mriFile, surfaces] = get_freeSurferAnat(mriDir, mriFile)
% get_freeSurferAnat
%       [mriFile, surfaces] = get_freeSurferAnat(mriDir, [])
%       [mriFile, surfaces] = get_freeSurferAnat(mriDir, mriFile)
    
%% MRI
if isempty(mriFile)
    % Find the MRI
    [Files, Bytes, Names] = dirr(mriDir, 'T1.mgz', 'name');
    if isempty(Names)
        % No match, return
        mriFile = [];
        surfaces = [];
        return
    end
    mriFile = Names{1};
end

%% Surfaces
[path] = fileparts(mriFile);
scalp = [];
Lh = [];
Rh = [];
Lw = [];
Rw = [];
innerSkull = [];

% cortex
Lh = fullfile(path, 'lh.pial');
Rh = fullfile(path, 'rh.pial');
if ~exist(Lh, 'file') || ~exist(Rh, 'file')
    % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select the 2 pial files');
    fc.setMultiSelectionEnabled(1);
    curDir = java.io.File(path);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
        selFiles = fc.getSelectedFiles();
        file = char(selFiles(1));
        if strfind(lower(file), 'lh.')
            Lh = file;
            Rh = char(selFiles(2));
        else
            Lh = char(selFiles(2));
            Rh = file;
        end

        % redefine the path for the surfaces
        [path] = fileparts(Lh);
    end
end
% white
Lw = fullfile(path, 'lh.white');
Rw = fullfile(path, 'rh.white');
if ~exist(Lh, 'file') || ~exist(Rh, 'file')
    % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select 2 white matter surface files');
    fc.setMultiSelectionEnabled(1);
    curDir = java.io.File(path);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
        selFiles = fc.getSelectedFiles();
        for j=1:length(selFiles)
            file = char(selFiles(1));
            if strfind(lower(file), 'lw.')
                Lw = file;
                Rw = char(selFiles(2));
            else
                Lw = char(selFiles(2));
                Rw = file;
            end
        end
    end
end
% Inner skull
Names = [];
[Files, Bytes, Names] = dirr(path, 'inner_skull', 'name');
if isempty(Names)
     % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select the inner skull file');
    curDir = java.io.File(path);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
       innerSkull = char(fc.getSelectedFile());
    end
else
    innerSkull = Names{1};
end

% Scalp
Names = [];
[Files, Bytes, Names] = dirr(path, 'outer_skin', 'name');
if isempty(Names)
     % Ask user to specify a file
    fc = javax.swing.JFileChooser();
    fc.setDialogTitle('Select the outer skin file');
    curDir = java.io.File(path);
    fc.setCurrentDirectory(curDir);
    returnVal = fc.showOpenDialog(fc);
    if ~returnVal
       scalp = char(fc.getSelectedFile());
    end
else
    scalp = Names{1};
end

%% Output Surfaces
surfaces = {scalp, Lh, Rh, Lw, Rw, innerSkull};
end