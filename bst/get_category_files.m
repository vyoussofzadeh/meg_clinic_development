function [DataFiles, ResultFiles] = get_category_files(selectedStudies, categoryKeyword)
% get_category_files: gets the files that match the specified category
% keyword.
%
% USAGE:    FileNamesA = get_category_files(selectedStudies, categoryKeyword, fileType)
%
% INPUT:    selectedStudies = vector of integers containing the study
%                               numbers to search
%           categoryKeyword = string representing the category to identify
%

% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 25-APRIL-2011    Creation
% -------------------------------------------------------------------------

sStudies = bst_get('ProtocolStudies');
DataFiles = {};
ResultFiles = {};
nFiles = 1;

% Data files
for i=1:length(selectedStudies)
    sStudy = sStudies.Study(selectedStudies(i));
    iData = bst_get('DataForDataList', selectedStudies(i), categoryKeyword);
    filenames = {sStudy.Data(iData).FileName};
    if ~isempty(filenames)
        DataFiles(nFiles:nFiles+length(filenames)-1) = filenames;
        nFiles = nFiles + length(filenames);
    end
end

% Result files
t=1;
for r=1:length(DataFiles)
    [sStudy,iStudy,iResult]=bst_get('ResultsForDataFile', DataFiles{r}, selectedStudies);
    for s = 1:length(iResult)
        if sStudy.Result(iResult(s)).isLink
            ResultFiles(t) = {sStudy.Result(iResult(1)).FileName};
            t=t+1;
        end
    end
end