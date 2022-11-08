function Stat = stat_weightedAverageFiles( FilesList, iTime )

    % Initialize output
    Stat = struct();

    % Progress bar
    bst_progressBar('start', 'Computing mean', 'Initialization...', 0, length(FilesList));

    MeanValues   = [];
    MeanMatName  = [];
    NbChannels   = 0;
    TimeVector   = [];
    n = length(FilesList);
    nAvgTotal = 0;
    NoWaitbar= 0;
    sProtocol = bst_get('ProtocolInfo');     
    totalSegments = 0;
    
    for iFile = 1:n
        incValue = iFile;
        statFile = [];
        if ~NoWaitbar
            bst_progressBar('text', ['Processing file : "' FilesList{iFile} '"...']);
            bst_progressBar('inc',  incValue);
        end
        
        statFile = fullfile(sProtocol.STUDIES, char(FilesList(iFile)));
        [matValues, matName, ChannelFlag, TimeVector, nAvg] = bst_readMatrixInFile(statFile, iTime);
        nAvgTotal = nAvgTotal + nAvg;
        
        % Get the number of segments that were used in calc these values
        % Find the number of segments and data for each result
        
        c=load(statFile,'Comment');
        commentStr = c.Comment;
        st = strfind(commentStr,'(');
        s = regexp(commentStr(st+1:length(commentStr)),'\s','split');
        ind = strfind(s,'segment');
        iNum = s(find(~cellfun(@isempty,ind)) - 1);
        nSegments = str2double(iNum);
        
        % Convert to double values and multiply by the number of segments
        matValues = double(matValues) .* nSegments;
        totalSegments = totalSegments + nSegments;
        
        % If file is first of the list
        if (iFile == 1)
            % Initialize data fields
            MeanValues = zeros(size(matValues));
            MeanMatName = matName;
            initTimeVector = TimeVector;
        % All other files
        else
            % If current matrix has not the same size than the others
            if ~all(size(MeanValues) == size(matValues))
                error(['All the data matrices should have the same size.' 10 ...
                       'Error for file: ' FilesList{iFile}]);
            elseif ~strcmpi(MeanMatName, matName)
                error(['All the result files should be of the same type (full results or kernel-only).' 10 ...
                       'Error for file: ' FilesList{iFile}]);
            % Check time values
            elseif (length(initTimeVector) ~= length(TimeVector)) && ~all(initTimeVector == TimeVector)
                error(['Time definition is not the same for all the files.' 10 ...
                       'Error for file: ' FilesList{iFile}]);
            end
        end
        
        MeanValues = MeanValues + matValues;
       
    end

    
    MeanValues = MeanValues ./ totalSegments;
    Stat.mean    = MeanValues;
    Stat.MatName = MeanMatName;
    % Time vector
    Stat.Time = TimeVector;
    % Compute final bad channels
    Stat.ChannelFlag = ones(NbChannels, 1);
    % Number of trials processed
    Stat.nAvg = nAvgTotal;
    Stat.Comment = [' (' num2str(totalSegments) ' segments)'];
end