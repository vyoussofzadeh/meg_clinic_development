% Build file names structure
filename = '/MEG_data/realtime/florin_esther/110316/sss/run03_trial1_imagine/run03_trial1_imagine_raw_sss.fif';
filelocation = '/MEG_data/realtime/florin_esther/110316/sss/run03_trial1_imagine';
FileNames = create_default_file_names(filename);
FileNames.filelocation = filelocation;
eveInfoFile = fullfile(FileNames.filelocation, [FileNames.protocol '_eventInfo.mat']);

% Extract events info - if no _ave.fif file exists, copy the _eventInfo.mat from a similar
% recording
[Events, AcqPars] = parse_aveFile_events(fullfile(FileNames.filelocation, FileNames.aveName));
save(eveInfoFile,'Events','AcqPars')

% Load the eventInfo file if not loaded already
load(eveInfoFile)

% Build ave description file or copy .ave from similar recording and update text 
FileNames = set_ave_description(FileNames, 'functional');
file = fullfile(FileNames.filelocation, FileNames.aveDescriptionFile);
replace_text_line(file, 6, '\t%s', ['outfile ' FileNames.filelocation '/' FileNames.cleanAveFileName])
replace_text_line(file, 7, '\t%s', ['logfile ' FileNames.filelocation '/' FileNames.logAveFileName])

% Extract events and create event file
extract_rawFile_events(Events, AcqPars, FileNames.filename, fullfile(FileNames.filelocation, FileNames.fxnlEvents));
