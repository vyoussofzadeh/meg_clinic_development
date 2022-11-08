function sFiles = process_spectral_analysis(currentStudyName)
% process_spectral_analysis: Groups similar events and runs brainstorm
% pipeline process for spectral analysis
%
% USAGE:    process_spectral_analysis(currentStudyName)   
%
% INPUT:    currrentStudyName = name of selected study
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 19-NOV-2010    Creation
% EB 07-APR-2011    Updated to use brainstorm pipeline file
% -------------------------------------------------------------------------

%% Select Files

[sStudy, iStudy]=bst_get('Study', currentStudyName);
% Find "raw" data
iDatas = bst_get('DataForDataList',iStudy, 'Raw');
% Don't include the last one since it most often is a differnt length than
% the 2 seconds
iDatas = iDatas(1:length(iDatas)-1);
% Get the Result file names
ResultFiles = sStudy.Result; 
dataIndices = [];
% Find only those result files that match the raw files
for i=1:length(iDatas)    
    pat=sStudy.Data(iDatas(i)).FileName;
    x=regexp({ResultFiles.FileName}, pat);
    c=cellfun(@isempty, x);
    dataIndices = [dataIndices find(c==0)];
end

FileNamesA = {sStudy.Result(dataIndices).FileName};
FileNamesB = [];

%% Process: [Experimental] Spectral decomposition and statistics
load(fullfile(char(GUI.DataSet.megClinicPath), 'bst_pipelines', 'spectral_decomp.mat'))
sFiles = bst_process('Run', Processes, FileNamesA, FileNamesB);
