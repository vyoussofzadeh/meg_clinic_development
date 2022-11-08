function [dataFiles, resultFiles] = mc_bst_extracttimechunks(FileNamesA, timeChunk, sampRate, iStudy)
% mc_bst_extracttimechunks: create new files according to time chunk length
%
% USAGE:    mc_bst_extracttimechunks(FileNamesA, timeChunk, sampRate)
%           
% INPUT:    FileNamesA = names of raw chunks
%           timeChunk = length of time of new files
%           sampRate = sampling rate of the data
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 20-August-2011 Creation
% -------------------------------------------------------------------------
global GlobalData
dataFiles = {};
resultFiles = {};
% Get global paths
sProtocolInfo = bst_get('ProtocolInfo');
studyPath = sProtocolInfo.STUDIES;
fileInd = 1;
newFileInd = 0;
disp('creating new files...')
while 1
    % load in the next file: This is the reference for the first time point
    f = fullfile(studyPath, FileNamesA{fileInd});
    sData = load(f);
    sNewData = sData;
    refTime = sData.Time(1);

    while length(sNewData.Time) < sampRate*timeChunk
        % concatenate two files
        fileInd = fileInd+1;
        if length(FileNamesA) < fileInd
            break;
        end
        f = fullfile(studyPath, FileNamesA{fileInd});
        sData = load(f);
        sNewData.F = [sNewData.F sData.F];
        sNewData.Time = 1:size(sNewData.F,2);
    end
    
    % Adjust the length of the file
    t = sampRate*timeChunk;
    if size(sNewData.F,2) < t
        break;
    end
    sNewData.F = sNewData.F(:,1:t);
    endTime = refTime + timeChunk;
    sNewData.Time = refTime:1/sampRate:endTime-(1/sampRate);
    sNewData.Comment = ['Raw (' num2str(refTime) 's,' num2str(endTime) 's)'];
    
    % save the new file
    newFileInd = newFileInd+1;
    p = fileparts(f);
    dataFiles{newFileInd} = fullfile(p,['data_block_temp' num2str(newFileInd) '.mat']);
    save(dataFiles{newFileInd}, '-struct', 'sNewData');
    
    % go to next file chunck or exit
    fileInd = fileInd + 1;
    if length(FileNamesA) < fileInd
        break;
    end
end
% now reload all the studies
sSubject = bst_get('Subject');
[sStudies, iStudies] = bst_get('StudyWithSubject',   sSubject.FileName);
db_reload_studies(iStudies);

% get results (sources) for these new data files
disp(['Input files: ' num2str(length(FileNamesA)) ', temp files: ' num2str(length(dataFiles))]);
for jj=1:length(dataFiles)
    [sStudy, iStudy, iResult] = bst_get('ResultsForDataFile',   dataFiles(jj));
    resultFiles{jj} = sStudy.Result(iResult).FileName;
end
