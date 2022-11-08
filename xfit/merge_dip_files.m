function merge_dip_files(varargin)
% merge_dip_files: callback function from MEG-Clinic, Merge Dipole Files 
%
% USAGE:    set(mergeButton, 'ActionPerformedCallback', {@merge_dip_files})
%
% Author:   Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 07-SEPT-2010    Creation
% -------------------------------------------------------------------------
% First get the info from the GUI
mergeDip = DipoleFit.MergeDip;
fileList = cellstr(char(mergeDip.MERGE_FILES));
mergeName = char(mergeDip.MERGE_NAME);

% Set the name of the output file
refFile = fileList{1};
[p,n,e] = fileparts(refFile);
outputFile = [p '/' mergeName];
disp(['Merged File: ' outputFile])

% All file need to have been created with similar parameters. Compare the
% file names to ensure consistancy.
% Reference
ind = min(strfind(n,'_'));
refCompName = [n(ind+1:length(n)) e];

% Copy the first file to output name
copyfile(refFile, outputFile);

fid = fopen(fileList{1}, 'rb', 'ieee-be');
% Get number of dipoles
fseek(fid,0,1);            % jump to the end
FileSize = ftell(fid);     % how many bytes
NumDipoles = FileSize/196; % size of the structure per dipole
disp(['Added: ' num2str(NumDipoles) ' dipoles'])
fclose(fid);

% Open the output file
reffid = fopen(outputFile,'a','ieee-be');

for j = 2:length(fileList)
    [p,n,e] = fileparts(fileList{j});
    ind = min(strfind(n,'_'));
    compName = [n(ind+1:length(n)) e];
    if ~strcmp(compName, refCompName)
        delete(outputFile)
        msg = sprintf('%s\n\n%s','These files were generated with different parameters or have different naming conventions.','Select similar files and/or rename and try again.');
        msgbox(msg, 'Merge Error','error');
        break
    end
    fid = fopen(fileList{j}, 'rb', 'ieee-be');
    % Get number of dipoles
    fseek(fid,0,1);            % jump to the end
    FileSize = ftell(fid);     % how many bytes
    NumDipoles = FileSize/196; % size of the structure per dipole
    % rewind file
    fseek(fid,0,-1); 


    % Build dipoles structure
    [bdip(1:NumDipoles)] = deal(struct('dipole',[],'begin',[],'end',[],...
       'r0',zeros(3,1),'rd',zeros(3,1),'Q',zeros(3,1),'goodness',[],'errors_computed',[],...
       'noise_level',[],'single_errors',zeros(5,1),'error_matrix',zeros(5,5),...
       'conf_vol',[],'khi2',[],'prob',[],'noise_est',[]));

    % Read each dipole
    for i = 1:NumDipoles,
       bdip(i).dipole = fread(fid,1,'int32');    % Which dipole in a multi-dipole set
       bdip(i).begin  = fread(fid,1,'float32');  % Fitting time range (start)
       bdip(i).end    = fread(fid,1,'float32');  % Fitting time range (stop)
       bdip(i).r0     = fread(fid,3,'float32');  % Sphere model origin
       bdip(i).rd     = fread(fid,3,'float32');  % Dipole location
       bdip(i).Q      = fread(fid,3,'float32');  % Dipole amplitude
       bdip(i).goodness        = fread(fid,1,'float32');  % Goodness-of-fit
       bdip(i).errors_computed = fread(fid,1,'int32');    % Have we computed the errors
       bdip(i).noise_level     = fread(fid,1,'float32');  % Noise level used for error computations
       bdip(i).single_errors   = fread(fid,5,'float32');  % Single parameter error limits
       bdip(i).error_matrix    = fread(fid,25,'float32'); % This fully describes the conf. ellipsoid
       bdip(i).conf_vol  = fread(fid,1,'float32');  % The xyz confidence volume
       bdip(i).khi2      = fread(fid,1,'float32');  % The khi^2 value
       bdip(i).prob      = fread(fid,1,'float32');  % Probability to exceed khi^2 by chance
       bdip(i).noise_est = fread(fid,1,'float32');  % Total noise estimate
    end 
    % Close file
    fclose(fid);

    % Go to the end of the reference file
    fseek(reffid,0,1);
    % write dipoles
    for i = 1:NumDipoles,
       count(i) = fwrite(reffid,bdip(i).dipole,'int32');    % Which dipole in a multi-dipole set
       count(i) = fwrite(reffid,bdip(i).begin ,'float32');  % Fitting time range (start)
       count(i) = fwrite(reffid,bdip(i).end,'float32');  % Fitting time range (stop)
       count(i) = fwrite(reffid,bdip(i).r0 ,'float32');  % Sphere model origin
       count(i) = fwrite(reffid,bdip(i).rd ,'float32');  % Dipole location
       count(i) = fwrite(reffid,bdip(i).Q ,'float32');  % Dipole amplitude
       count(i) = fwrite(reffid,bdip(i).goodness ,'float32');  % Goodness-of-fit
       count(i) = fwrite(reffid,bdip(i).errors_computed ,'int32');    % Have we computed the errors
       count(i) = fwrite(reffid,bdip(i).noise_level,'float32');  % Noise level used for error computations
       count(i) = fwrite(reffid,bdip(i).single_errors ,'float32');  % Single parameter error limits
       count(i) = fwrite(reffid,bdip(i).error_matrix ,'float32'); % This fully describes the conf. ellipsoid
       count(i) = fwrite(reffid,bdip(i).conf_vol ,'float32');  % The xyz confidence volume
       count(i) = fwrite(reffid,bdip(i).khi2 ,'float32');  % The khi^2 value
       count(i) = fwrite(reffid,bdip(i).prob ,'float32');  % Probability to exceed khi^2 by chance
       count(i) = fwrite(reffid,bdip(i).noise_est ,'float32');  % Total noise estimate
    end
    totalCount = sum(count);
    disp(['Added: ' num2str(totalCount) ' dipoles'])
    clear count

end
fclose(reffid);