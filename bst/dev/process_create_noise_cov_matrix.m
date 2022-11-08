function process_create_noise_cov_matrix(emptyRoomStudyDir, emptyRoomStudyName, currentStudyName)

% ===== NOISE COVARIANCE MATRIX =====

% Get study corresponding to the empty room
[sStudy, iStudy] = bst_get('Study', emptyRoomStudyName);
NoiseCovFile = fullfile(emptyRoomStudyDir, sStudy.NoiseCov.FileName);
if isempty(NoiseCovFile)
    iDatas = bst_get('DataForDataList',iStudy, 'Raw');
    NoiseCovMat.NoiseCov = bst_noisecov(iStudy, [], iDatas); 
    NoiseCovMat.Comment  = 'Noise covariance';
else
    NoiseCovMat = import_noisecov([], NoiseCovFile);
    % TODO Check the size of matrix (384 vs 321)
end

% Import it in database (do not ask user confirmation for replacement of previous files)
[sStudy, iStudy] = bst_get('Study', currentStudyName);
AutoReplace = 1;
import_noisecov(iStudy, NoiseCovMat, AutoReplace);

% USAGE:  NoiseCov = bst_noisecov(iTargetStudies, iDataStudies, iDatas, Options)                      
%         NoiseCov = bst_noisecov(iTargetStudies, iDataStudies, iDatas) : Use only the specified recordings
%         NoiseCov = bst_noisecov(iTargetStudies)                       : Use all the recordings from these studies
%
% INPUT: 
%     - iTargetStudies : List of studies indices for which the noise covariance matrix is produced
%     - iDataStudies   : [1,nData] int, List of data files to use for computation (studies indices)
%                        If not defined or [], uses all the recordings from all the studies (iTargetStudies)
%     - iDatas         : [1,nData] int, List of data files to use for computation (data indices)
%     - Options        : Structure with the following fields (if not defined: asked to the user)
%           |- Baseline        : [tStart, tStop]; range of time values considered as baseline
%           |- NoiseCovMethod  : {'diag', 'full'}; diag computes the full matrix but keep only the diagonal
%           |- RemoveDcOffset  : {'all', 'file'}; 'all' removes the baseline avg file by file; 'all' computes the baseline avg from all the files


% Options: compute diagonal matrix, remove baseline
%Options.Baseline = []; %[-0.200 -0.005];
%Options.Method   = 'diag';

%% Computation

% To specify options
iDatas = bst_get('DataForDataList',iStudy, 'Raw');
NoiseCovMat.NoiseCov = bst_noisecov(iStudy, [], iDatas); 
NoiseCovMat.Comment  = 'Noise covariance';

% Import it in database (do not ask user confirmation for replacement of previous files)
AutoReplace = 1;
import_noisecov(iStudy, NoiseCovMat, AutoReplace);

% Display message
disp('Done.');