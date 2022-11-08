function OutputFiles = process_category_weightedAverage(processType)
% process_category_average: performs a grand average accross all recordings
%
% USAGE:    process_category_average('spectDecomp')     % Do average on all ongoing (raw) data chunks
%           process_category_average('recMaps')         % Do average on recurrence maps for each event
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 21-MAY-2010    Creation
% -------------------------------------------------------------------------

%% Get Categories
sStudies = bst_get('ProtocolStudies');
offset = 1;
comments = {};
for i=1:length(sStudies.Study)
    if ~isempty(sStudies.Study(i).Result)
        sStudy = sStudies.Study(i);
        ResultFiles = sStudy.Result;
        % Filter results
        x=regexp({ResultFiles.FileName}, processType);
        c=cellfun(@isempty, x);
        dataIndices = find(c==0);
        if ~isempty(dataIndices)
            % Find categories
            ind = strfind({ResultFiles(dataIndices).Comment}, '(');
            for k=1:length(dataIndices)       
                comments(offset) = {ResultFiles(dataIndices(k)).Comment(1:ind{k}-2)};
                offset = offset+1;
            end
        end
    end
end

if isempty(comments)
    return;
end
categories = unique(comments);
x=strcmp(categories, 'Low-high freq constrast');
iCateg = find(~x);
categories = categories(iCateg);

%% Delete existing @intra category averages
sProtocol = bst_get('ProtocolInfo');     
for j=1:length(categories)
    pattern = char(categories(j));
    intraStudy = find(strcmp({sStudies.Study.Name}, '@intra'));
    x=regexp({sStudies.Study(intraStudy).Result.Comment}, pattern);
    iResult = find(~cellfun(@isempty,x));
    if ~isempty(iResult)
        % Remove this file (without confirmation), it will be recalculated
        io_deleteFile(fullfile(sProtocol.STUDIES, sStudies.Study(intraStudy).Result(iResult).FileName),1);    
    end
end
% Reload study folder (necessary, because we deleted manually some files, 
% without removing their references in the database)
db_reloadStudies(intraStudy);
sStudies = bst_get('ProtocolStudies');

%% Find Category Files
% Loop through each category and find matching results across all studies

for j=1:length(categories)
    Filenames = {};
    pattern = char(categories(j));
    offset = 1;
    for k=1:length(sStudies.Study)
        if ~isempty(sStudies.Study(k).Result) && ~strcmp(sStudies.Study(k).Name, '@intra')
            sStudy = sStudies.Study(k);
            ResultFiles = sStudy.Result;
            % Filter results
            x=regexp({ResultFiles.Comment}, pattern);
            c=cellfun(@isempty, x);
            dataIndices = find(c==0);
            if ~isempty(dataIndices)
                % Find unique categories
                start = 0+offset;
                stop = offset+length(dataIndices)-1;
                Filenames(start:stop) = {ResultFiles(dataIndices).FileName};
                offset = offset+length(dataIndices);
            end
        end
    end

    %% Weighted Average across categories
    if ~isempty(Filenames) && length(Filenames) > 1
        panel_processes('ResetPanel');
        % Add files to the Processes panel
        nFiles = gui_stat_common('SetFilesToProcess', 'Processes', Filenames);
        if (nFiles == 0)
            return;
        end

        % Set type of files to process to data
        isData = 0; 
        if isData
            panel_processes('SetFileType', 'data');
        else
            panel_processes('SetFileType', 'results');
        end
        % Conditions: structure that define the files in the Processes list
        Conditions = gui_stat_common('GetConditions', 'Processes');

        % ===== GET PROCESS =====
        % Get processes list, and pick a process in it
        sProcessesList = panel_statRun('GetProcessesList', 'All');
        % Find a process using its name
        ProcessName = 'meanA';
        iProc = find(strcmpi({sProcessesList.Name}, ProcessName));
        if isempty(iProc)
            error('Process not found.');
        end
        % Process to use
        sProcess = sProcessesList(iProc);

        % ===== TIME =====
        if BrainstormIO.BstConfig.TIMEWIN
            %Use specific time window
            TimeVector = panel_statRun('GetFileTimeVector', Conditions.SamplesA(1).iStudy, Conditions.SamplesA(1).iItem, isData);
            Time  = [BrainstormIO.BstConfig.TSTART, BrainstormIO.BstConfig.TSTOP];
            iTime = find(TimeVector > Time(1) & TimeVector < Time(2));
        else
            % Use all the time samples
            TimeVector = panel_statRun('GetFileTimeVector', Conditions.SamplesA(1).iStudy, Conditions.SamplesA(1).iItem, 'results');
            Time  = [TimeVector(1), TimeVector(end)];
            iTime = 1:length(TimeVector);
        end


        % ===== DEFINE OPTIONS =====
        OPTIONS.Conditions       = Conditions;    % Files to process
        OPTIONS.sProcess         = sProcess;      % Process to apply
        OPTIONS.DataType         = 'results';        % Process data or recordings
        OPTIONS.isData           = 'results';
        OPTIONS.Comment          = [pattern '_weightedAve']; % Default comment for output files (might be overridden)
        OPTIONS.OutputType       = 'database';    % Where o store the results: {database, file, matlab}
        OPTIONS.ForceOutputCond  = [];            % When you want to store the result in a specific condition (used only when OutputType='database')=> Ex. 'Subject01/@intra'
        OPTIONS.isOverwriteFiles = 0;             % Overwrite input files, only in the case of filters (one input file = one output file)
        OPTIONS.isAbsoluteValues = 1;             % Compute the absolute value of the data before applying the process (usually 1 for sources, 0 for recordings)
        OPTIONS.Time             = Time;          % Time window to process [tStart, tStop] in seconds
        OPTIONS.iTime            = iTime;         % Time window: Indices in time vector for the full file
        OPTIONS.Baseline         = [];      % Some processes requires a baseline definition (it is the case for the zscore)
        OPTIONS.iBaseline        = [];     % => Baseline and iBaseline work exactly the same way as Time and iTime
        % Other options we do not use here:
        OPTIONS.nbPermutation    = 0;    % For permuation tests only
        OPTIONS.isCluster        = 0;    % Extract only some clusters/scouts values
        OPTIONS.isClusterAverage = 0;    % If 1, group all the clusters/scouts; If 0, consider they are separate
        OPTIONS.sClusters        = [];   % Array of scouts/clusters structures
        OPTIONS.ClustersOptions  = [];   % Structure that defines how the clusters/scouts values are computed (fields: function, isAbsolute)


        % Call processing function
        SamplesA = OPTIONS.Conditions.SamplesA;
        [OutputFiles, iStudyToRedraw] = BatchWeightedAverage(SamplesA, OPTIONS);
        
        % ===== UPDATE INTERFACE =====
        % OUTPUT TYPE: DATABASE ONLY
        if strcmpi(OPTIONS.OutputType, 'database') && ~isempty(iStudyToRedraw)
            iStudyToRedraw = unique(iStudyToRedraw);
            % Unload all datasets
            bst_dataSetsManager('UnloadAll', 'Forced', 'KeepScouts');
            % Update results links in target study
            db_links('Study', iStudyToRedraw);
            % Update tree model
            tree_updateNode('Study', iStudyToRedraw);
            % Select target study as current node
            tree_selectStudyNode( iStudyToRedraw(1) );
            % Save database
            db_save();
            % Select output file, if there is only one
            if (length(OutputFiles) == 1)
                tree_selectNode(OutputFiles{1});
            end
        end
        % Hide waitbar
        bst_progressBar('stop');
    end
end
        
        
        
        