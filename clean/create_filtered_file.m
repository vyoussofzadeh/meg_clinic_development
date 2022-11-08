function filteredFile = create_filtered_file(mc, FileNames)

wf = GUI.DataSet.currentWorkflow;
% Get workflow variables
mask = char(wf.getName(GUI.WorkflowConfig.MASK));
stimSource = char(wf.getName(GUI.WorkflowConfig.STIMSOURCE));

% Get filter frequencies
hp = char(ArtifactClean.CleanConfig.FILTERHP);
lp = char(ArtifactClean.CleanConfig.FILTERLP);

% Create Name
[p,n,e,v] = fileparts(FileNames.filename);
filteredFile = fullfile(p, [n '_' hp '-' lp 'Hz_raw.fif']);

% Filter file and save
command = ['mne_process_raw --cd ' FileNames.filelocation ' --raw ' FileNames.filename ' --projon --save ' filteredFile ' --digtrig ' stimSource ' --digtrigmask ' mask ' --highpass ' hp ' --lowpass ' lp];
% logFile.write(['command: ' command]);
[s, w] = unix(command);
% logFile.write(w);
% disp(w)