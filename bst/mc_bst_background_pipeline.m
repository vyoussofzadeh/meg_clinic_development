function sFiles = mc_bst_background_pipeline(selectedStudies)
% mc_bst_background_pipeline: runs the background pipeline for MEG-Clinic
%
% USAGE:    sFiles = mc_bst_background_pipeline(selectedStudies)
%
% INPUT:    selectedStudies = list of study indices
%
% OUTPUT:   sFiles = structure containing information about the brainstorm
% result files
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 10-JULY-2011    Creation
% -------------------------------------------------------------------------

sFiles = [];
%% Compute sources
sourcesStudies = [];
sourcesStudies = mc_bst_compute_sources(selectedStudies);


%% Spectral decomposition
configOptions = BrainstormIO.BstConfig.getConfigOptions();
ind = double(BrainstormIO.BstConfig.ADJUST_WIN) + 1; % Java uses zero indexing
if configOptions(ind)
    % Use different window lengths based on the median frequency of thebands
    sFiles = mc_bst_compute_spect_decomp_adjust(selectedStudies);
else
    % Use 2 sec window
    if isempty(sourcesStudies)
        sFiles = mc_bst_compute_spect_decomp(selectedStudies);
    else
        sFiles = mc_bst_compute_spect_decomp(sourcesStudies);
    end
end


%% Project spectral maps to colin27 brain
% colin27 brain
sSubject = bst_get('Subject', '@default_subject');
sSurface = bst_get('SurfaceFileByType', sSubject.FileName, 'Cortex');
destSurfFile = sSurface.FileName;
% Loop through all result files
for ii=1:length(sFiles)
    ResultsFile = {sFiles(ii).FileName}; 
    bst_project_sources( ResultsFile, destSurfFile, 1 )
end

%% Get FileNames for contrast
% FileNames A
% cond = {sFiles.Condition};
% conds = cellfun(@(x)(mat2str(x)),cond,'uniformoutput',false);
% studiesToContrast = unique(conds); 
% sStudies = bst_get('StudyWithSubject', sSubject.FileName)
% for jj = 1:length(studiesToContrast)
%     regexp({sStudies.Name}, studiesToContrast{jj})
% %% process_contract_indiv2group
% FileNamesA = [];
% FileNamesB = [];
% % for each study
% sStudies = bst_get('StudyWithSubject', '@default_subject/brainstormsubject.mat');
% for jj=1:length(sStudies)
%     % Process: Contrast individual (A) to group (B) maps
%     sFiles = bst_process(...
%         'CallProcess', 'process_contrast_indiv2group', ...
%         FileNamesA, FileNamesB);
% 
% end
% 
% %% get_groupanalysis_results
% function FileNamesA = get_groupanalysis_results(fComments)
%  
% FileNamesA = {};
% sStudies = bst_get('StudyWithSubject', '@default_subject/brainstormsubject.mat');
% nFiles = 1;
% for jj=1:length(sStudies)
%     ResultFiles = sStudies(jj).Result;
%     % find result files that match the comments 
%     for kk=1:length(fComments)
%         pat = char(fComments{kk});
%         index=strfind({ResultFiles.Comment}, pat);
%         ind = find(~cellfun(@isempty, index));
%         FileNamesA = {FileNamesA ResultFiles{ind}};
%     end
% end