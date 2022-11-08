function Stat = calc_weightedAverage( StatType, FilesListA, FilesListB, varargin )

% Initialize output
Stat = struct();
% If 'NoWaitbar' option
NoWaitbar = 0;
isAbsoluteValues = 0;
PercentProgressBar = 0;
incValue = 1;
iTimeA = [];
iTimeB = [];
isApplyNavg = -1;
if ~isempty(varargin)
    for i=1:length(varargin)
        if ischar(varargin{i}) && strcmpi(varargin{i}, 'NoWaitbar')
            NoWaitbar = 1;
        elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'AbsoluteValues')
            isAbsoluteValues = 1;
        elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'PercentProgressBar')
            PercentProgressBar = 1;
        elseif isnumeric(varargin{i}) && (numel(varargin{i}) == length(varargin{i})) && isempty(iTimeA) 
            iTimeA = varargin{i};
        elseif isnumeric(varargin{i}) && (numel(varargin{i}) == length(varargin{i}))
            iTimeB = varargin{i};
        end
    end
end
% Progress bar
if ~NoWaitbar && ~PercentProgressBar
    bst_progressBar('start', 'Computing mean', 'Initialization...', 0, length(FilesListA));
elseif PercentProgressBar
    incValue = ceil(100 / length(FilesListA));
end
% Compute mean
[tmp__, MeanValues, StatBadChannels, StatMatName, NbChannels, TimeVector, nAvg] = getMeanValues(FilesListA, 0, iTimeA);
% Return values
Stat.mean    = MeanValues;
Stat.MatName = StatMatName;
end

%% Compute weighted average
function [VarValues, MeanValues, MeanBadChannels, MeanMatName, NbChannels, TimeVector, nAvgTotal] = getMeanValues(FilesList, computeVariance, iTime)
    VarValues    = [];
    MeanValues   = [];
    MeanMatName  = [];
    NbChannels   = 0;
    TimeVector   = [];
    nGoodSamples = [];
    isData = 0;
    n = length(Filenames);
    nAvgTotal = 0;


    for iFile = 1:n
        if ~NoWaitbar
            bst_progressBar('text', ['Processing file : "' FilesList{iFile} '"...']);
            bst_progressBar('inc',  incValue);
        end
        
        [matValues, matName, ChannelFlag, TimeVector, nAvg] = bst_readMatrixInFile(fullfile(sProtocol.STUDIES, char(Filenames(n))));
        nAvgTotal = nAvgTotal + nAvg;
        % Convert to double values
        matValues = double(matValues);
        % Apply absolute values if necessary
        if isAbsoluteValues
            matValues = abs(matValues);
        end
        % If file is first of the list
        if (iFile == 1)
            % Initialize data fields
            MeanValues = zeros(size(matValues));
            if computeVariance
                VarValues = zeros(size(matValues));
            end
            MeanMatName = matName;
            % If processing recordings (="data") files
            isData = strcmpi(MeanMatName, 'F');
            % Good channels
            NbChannels   = length(ChannelFlag);
            nGoodSamples = zeros(NbChannels, 1);
            % Initial Time Vector
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
        % Get good channels
        iGoodRows = (ChannelFlag == 1);
        nGoodSamples(iGoodRows) = nGoodSamples(iGoodRows) + 1;
        
        MeanValues = MeanValues + matValues;
       
    end
    % Bad channels = channels that are BAD in ALL the samples
    if (NbChannels > 0)
        MeanBadChannels = find(nGoodSamples == 0);
    else
        MeanBadChannels = [];
    end
    
    MeanValues = MeanValues ./ n;
    Stat.mean    = MeanValues;
    Stat.MatName = StatMatName;
    % Time vector
    Stat.Time = TimeVector;
    % Compute final bad channels
    Stat.ChannelFlag = ones(NbChannels, 1);
    Stat.ChannelFlag(StatBadChannels) = -1;
    % Number of trials processed
    Stat.nAvg = nAvg;
end