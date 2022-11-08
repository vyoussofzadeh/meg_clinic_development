function [FileName, iStudyToRedraw] = BatchWeightedAverage(SamplesA, OPTIONS)
    % Get process
    sProcess = OPTIONS.sProcess;
    % Get output study
    sStudies = bst_get('ProtocolStudies');
    [sTargetStudy, iTargetStudy] = bst_get('Study',find(strcmp({sStudies.Study.Name}, '@intra')));
    % Update this study
    iStudyToRedraw = iTargetStudy;
    % If no valid output study can be found
    if isempty(iTargetStudy)
        OutputFiles = {};
        return;
    end
        
    % === PROCESS AVERAGE ===
    bst_progressBar('start', ['Apply process: ' sProcess.Name], 'Initialization...', 0, length(SamplesA));
    % If absolute values
    if OPTIONS.isAbsoluteValues
        strAbsolute = 'AbsoluteValues';
    else
        strAbsolute = [];
    end

    % Compute Average
    Stat = stat_weightedAverageFiles({SamplesA.FileName}, OPTIONS.iTime);
    
    %% === SAVE RESULTS ===
    % Resolve link, if it is a link
    [FileName, DataFile] = resolveResultsLink(SamplesA(1).FileName);
    % Load file
    sFileMat = load(FileName);
    % Stat
    % Time
    sFileMat.Time = OPTIONS.iTime;
    sFileMat.ImageGridTime = Stat.Time;
    % Reset some fields
    sFileMat.ImagingKernel = [];
    sFileMat.ImageGridAmp  = [];
    sFileMat.DataFile = [];
    
    % Add HeadModelType field if does not exist yet
    if ~isfield(sFileMat, 'HeadModelType')
        sFileMat.HeadModelType = 'surface';
    end
    % Remove "Kernel" indications in the Comment field
    sFileMat.Comment = strrep(sFileMat.Comment, '(Kernel)', '');
    sFileMat.Comment = strrep(sFileMat.Comment, 'Kernel', '');
    % Add averaged values in it
    sFileMat.(Stat.MatName) = Stat.mean;
    % Comment
    sFileMat.Comment = [OPTIONS.Comment Stat.Comment];

    % Add the number of files averaged to create this one
    sFileMat.nAvg = Stat.nAvg;
    % History: Average
    strAverage = [sprintf('Average of %d files ', length(SamplesA)), 0];
    if isfield(sFileMat, 'History')
        prevHistory = sFileMat.History;
        sFileMat = bst_history('reset', sFileMat);
        sFileMat = bst_history('add', sFileMat, ' weighted average', [strAverage ' - History of the 1st file:']);
        sFileMat = bst_history('add', sFileMat, prevHistory, ' - ');
        sFileMat = bst_history('add', sFileMat, ' average', 'Average completed.');
    else
        sFileMat = bst_history('add', sFileMat, 'weighted average', strAverage);
    end
    % Save and register file
    % Get protocol directories
    ProtocolInfo = bst_get('ProtocolInfo');
    % Get default output file
    OutputDir = fullfile(ProtocolInfo.STUDIES, bst_fileparts(sTargetStudy.FileName));
    c = clock;
    strTime = sprintf('_%02.0f%02.0f%02.0f_%02.0f%02.0f', c(1)-2000, c(2:5));
    fileTag = 'results';
    strInputTags = '';
    % Default filename
    defFileName = [fileTag '_' sProcess.Name strTime strInputTags '.mat'];
    % File in the target study
    OutputFile = fullfile(OutputDir, defFileName);
    % Make filename unique
    OutputFile = io_makeUniqueFilename(OutputFile);
    % Save in database
    save(OutputFile, '-struct', 'sFileMat');
    % Register in database
    FileName = strrep(OutputFile, ProtocolInfo.STUDIES, '');
    sTargetStudy = db_addData(iTargetStudy, FileName, sFileMat);
end

