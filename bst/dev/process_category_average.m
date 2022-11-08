function process_category_average(selectedStudies)
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
offset = 1;
for i=1:length(selectedStudies)
    [sStudy, iStudy] = bst_get('Study', selectedStudies(i));
    
    if ~isempty(sStudy.Result)
        ResultFiles = sStudy.Result;
        % Filter results
        pat='results_decomp';
        index=strfind({ResultFiles.FileName}, pat);
        dataIndices = find(~cellfun(@isempty, index), 1);
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

categories = unique(comments);
x=strcmp(categories, 'Low-high freq constrast');
iCateg = find(~x);
categories = categories(iCateg);

%% Delete existing @intra category averages
sProtocol = bst_get('ProtocolInfo');     
for j=1:length(categories)
    pattern = char(categories(j));
    iStudy = find(strcmp({sStudies.Study.Name}, '@intra'));
    x=regexp({sStudies.Study(2).Result.Comment}, pattern);
    iResult = find(~cellfun(@isempty,x));
    if ~isempty(iResult)
        % Remove this file (without confirmation), it will be recalculated
        io_deleteFile(fullfile(sProtocol.STUDIES, sStudies.Study(iStudy).Result(iResult).FileName),1);    
    end
end
% Reload study folder (necessary, because we deleted manually some files, 
% without removing their references in the database)
db_reloadStudies(iStudy);
sStudies = bst_get('ProtocolStudies');

%% Find Category Files
% Loop through each category and find matching results across all studies

for j=1:length(categories)
    Filenames = {};
    pattern = char(categories(j));
    offset = 1;
    for k=1:length(sStudies.Study)
        nSegments = 0;
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
                
                % Find the number of segments and data for each result
                commentStr = sStudies.Study(k).Result(dataIndices).Comment;
                st = strfind(commentStr,'(');
                s = regexp(commentStr(st+1:length(commentStr)),'\s','split');
                ind = strfind(s,'segment');
                iNum = s(find(~cellfun(@isempty,ind)) - 1);
                nSegments = nSegments + str2double(iNum);
            end
        end
    end
    
    %% Average Category
    % Remove previous nodes in the Processes panel
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
        OPTIONS.Comment          = [pattern '_meanA']; % Default comment for output files (might be overridden)
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
        OutputFiles = bst_batch(OPTIONS);
    end
end
        
        
        
        