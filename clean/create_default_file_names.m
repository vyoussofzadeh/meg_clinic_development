function FileNames = create_default_file_names(filename)

config = ArtifactClean.CleanConfig;

FileNames.filename = filename;
eveTag = char(config.ECG_EVENTS);
ecgProjTag = char(config.ECG_PROJ);
ogProjTag = char(config.ONGOING_PROJ);
cleanTag = char(config.CLEANTAG);
aveTag = char(config.ECG_AVETAG);
FileNames.aveName = '';

eogEventTag = char(config.EOG_EVENTS);
eogProjTag = char(config.EOG_PROJ);

% make file names
[path,name,ext] = fileparts(filename);
name = [name ext]; 
index = min(regexp(name,'_raw'));

% protocol name, ave desc and fxnl events use subname
subname = name(1:index-1);
FileNames.rawAveName = [subname '_ave.fif'];

% Check for the -1 from longer names
if strfind(name, '_raw-1')
    subname = [subname '-1'];
end
FileNames.protocol = subname;
FileNames.aveDescriptionFile = [subname '.ave'];
FileNames.fxnlEvents = [subname '.eve'];

% Get the basename
index = strfind(lower(name), 'clean');
if ~isempty(index)
    temp = name(1:index-1);
    % find closest underscore to clean and remove everything after
    index = max(strfind(temp, '_'));
    basename = temp(1:index-1);
elseif strfind(name, '_raw.fif')
    % remove the _raw from the end of the file
    basename = name(1:length(name)-8);
else
    index = max(strfind(name,'.'));
    basename = name(1:index-1);
end

% All files resulting from cleaning are built on the basename
FileNames.eventFileName = strcat(basename,eveTag,'.fif');
FileNames.ecgProjFileName = strcat(basename,ecgProjTag,'.fif');
FileNames.ecgCleanFileName = strcat(basename, '_ecgClean_raw.fif');
FileNames.eogEventFileName = strcat(basename, eogEventTag, '.fif');
FileNames.eogProjFileName = strcat(basename, eogProjTag, '.fif');
FileNames.eogCleanFileName = strcat(basename, '_eogClean_raw.fif');
FileNames.ogProjFileName = strcat(basename, ogProjTag,'.fif');
FileNames.ogCleanFileName = strcat(basename, '_ongoingClean_raw.fif');
FileNames.cleanFileName = strcat(basename, cleanTag , '_raw.fif');
FileNames.cleanAveFileName = strcat(basename, cleanTag , '_ave.fif');
FileNames.logAveFileName = strcat(basename, cleanTag , '_ave.log');

