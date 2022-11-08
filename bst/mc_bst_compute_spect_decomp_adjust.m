function OutputFiles = mc_bst_compute_spect_decomp_adjust(varargin)
% mc_bst_compute_spect_decomp_adjust: compute spectral decomposition with
% adjustable window sizes
%
% USAGE:    mc_bst_compute_spect_decomp_adjust(selectedStudies)
%           
% INPUT:    list of studies to pull raw files from
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 20-August-2011 Creation
% -------------------------------------------------------------------------
global GlobalData

OutputFiles = [];
FileNamesA = [];
FileNamesB = [];
selectedStudies = varargin{1};
if nargin == 2
    FileNamesA = varargin{2};
    includedStudies = selectedStudies;
else

    % Get global paths
    sProtocolInfo = bst_get('ProtocolInfo');
    studyPath = sProtocolInfo.STUDIES;
    includedStudies = [];
    for j=1:length(selectedStudies)
        % Select the study
        [sStudy, iStudy] = bst_get('Study', selectedStudies(j));
        fileName = sStudy.Name;
        panel_protocols('SelectStudyNode', iStudy);

        % Delete any existing *_block_temp*.mat files - these are created here
        delete(fullfile(studyPath, fileparts(sStudy.FileName), '*_block_temp*.mat'))
        % now reload the studies
        db_reload_studies(iStudy);

        % Find existing results
        ResultFiles = sStudy.Result;
        % Filter results
        pat='results_decomp';
        ind=strfind({ResultFiles.FileName}, pat);
        dataIndices = find(~cellfun(@isempty, ind), 1);
        % If results already exist, exit this pipeline
        if ~isempty(dataIndices)
            text = sprintf('MC>Results already exist for study %d...this study is not included in the current results', selectedStudies(j));
            disp(text)
            continue;
        end
        % Generate Results
        % Find "raw" data
        iDatas = bst_get('DataForDataList',iStudy, 'Raw');
        % Don't include the last one since it most often is a different length than
        % the 2 seconds
        iDatas = iDatas(1:length(iDatas)-1);
        includedStudies = [includedStudies selectedStudies(j)];
        FileNamesA = [FileNamesA {sStudy.Data(iDatas).FileName}];
    end
end

% Check output studies
if isempty(includedStudies)
    return;
end

% Process: [Experimental] Spectral decomposition and statistics
% Get freq bands
bands = get_sessionFrequencyBands();

for ii = 1:size(bands,1)    
    % determine the time chunk (n periods of the median freq)
    nPeriods = 10;
    timeChunk = (ceil((1/median(bands{ii,2}:bands{ii,3}))*1000)*nPeriods)/1000;
    % redefine the chunks
    text = sprintf('MC>Spec decomp for %s band using %d sec window', bands{ii,1},timeChunk);
    disp(text)
    DataMat = in_bst_data(FileNamesA{1});
    samplingRate = ceil(1 ./ (DataMat.Time(2)-DataMat.Time(1)));
    [dataFiles, resultFiles] = mc_bst_extracttimechunks(FileNamesA, timeChunk, samplingRate);
    
    sFiles = bst_process(...
        'CallProcess', 'process_spect_decomp2', ...
        resultFiles, [], ...
        'freqbands', bands(ii,:));
    
    OutputFiles = [OutputFiles sFiles];
    
    % Delete the temp files
    for jj = 1:length(dataFiles)
        delete(dataFiles{jj})
    end
    % now reload all the studies
    sSubject = bst_get('Subject');
    [sStudies, iStudies] = bst_get('StudyWithSubject',   sSubject.FileName);
    db_reload_studies(iStudies);
end

end %end funtion

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
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING,'Cannot parse session frequency information.  Using the default frequency bands.');
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
