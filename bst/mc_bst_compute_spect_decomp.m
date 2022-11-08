function sFiles = mc_bst_compute_spect_decomp(varargin)
% mc_bst_compute_spect_decomp: compute spectral decomposition
%
% USAGE:    mc_bst_compute_spect_decomp(selectedStudies)
%           
% INPUT:    list of studies to pull raw files from
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 12-JULY-2011 Creation
% -------------------------------------------------------------------------
sFiles = [];
FileNamesA = [];
FileNamesB = [];
selectedStudies = varargin{1};
if nargin == 2
    FileNamesA = varargin{2};
else
    for j=1:length(selectedStudies)
        % Select the study
        [sStudy, iStudy] = bst_get('Study', selectedStudies(j));
        panel_protocols('SelectStudyNode', iStudy);

        % Find existing results
        ResultFiles = sStudy.Result;
        % Filter results
        pat='results_decomp';
        ind=strfind({ResultFiles.FileName}, pat);
        dataIndices = find(~cellfun(@isempty, ind), 1);
        if isempty(dataIndices)
            pat='Raw';
            ind = strfind({sStudy.Data.Comment}, pat);
            iData = find(~cellfun(@isempty, ind));
            for jj=1:length(iData)
                [~, ~, iResults] = bst_get('ResultsForDataFile', sStudy.Data(iData(jj)).FileName, []);
                FileNamesA = [FileNamesA {sStudy.Result(iResults).FileName}];
            end
        end
    end
end

% Process: [Experimental] Spectral decomposition and statistics
% Get freq bands
bands = get_sessionFrequencyBands();

for ii=1:size(bands,1)
    sFiles = bst_process(...
    'CallProcess', 'process_spect_decomp2', ...
    FileNamesA, FileNamesB, ...
    'freqbands', bands(ii,:));
end
end

%% Get Freqs
function options = get_sessionFrequencyBands()
    % Try to get the session frequencies
    try
        freq = char(GUI.DataSet.currentSession.getType(GUI.Session.FREQBANDS));        
        st = regexp(freq, ':')+1;
        en = regexp(freq, ';')-1;
        nName = [1 en+3];        
        for i=1:length(st)
            options (i,1)= {freq(nName(i): st(i)-2)};
            nums = str2num(freq(st(i):en(i)));
            options (i, 2) = {nums(1)};
            options (i, 3) = {nums(2)};
        end

        % Otherwise use the default
    catch ME
        options(1,1) = {'delta'};
        options(1,2) = {1};
        options(1,3) = {4};
        options(2,1) = {'theta'};
        options(2,2) = {4};
        options(2,3) = {8};
        options(3,1) = {'alpha'};
        options(3,2) = {8};
        options(3,3) = {12};
        options(4,1) = {'beta1'};
        options(4,2) = {12};
        options(4,3) = {25};
        options(5,1) = {'beta2'};
        options(5,2) = {25};
        options(5,3) = {35};
        options(6,1) = {'gamma1'};
        options(6,2) = {35};
        options(6,3) = {55};
        options(7,1) = {'gamma2'};
        options(7,2) = {70};
        options(7,3) = {110};
        options(8,1) = {'gamma3'};
        options(8,2) = {130};
        options(8,3) = {170};
        options(9,1) = {'gamma4'};
        options(9,2) = {250};
        options(9,3) = {500};
    end
end
