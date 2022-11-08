%function mc_bst_batch()

% find selected files for import
selectedPaths = mc.getSelectionPaths();
nFiles = selectedPaths.length;
for i=1:nFiles
    im{i} = char(selectedPaths.get(i-1));
end

% find all spike event types
[eventNames, eventTypes] = extract_annot_event_types(im);
% Get the sss path
sssPath = char(GUI.DataSet.sssDataPath);
% find all spont files
[Files, Bytes, spontNames] = dirr([sssPath '/*spont*lean_raw.fif'], 'name');

if isempty(eventTypes)
    eve = [];
else
    % convert the event types to a cell array of strings
    eve = strtrim(cellstr(num2str(eventTypes'))');
end

% start batch dialog
batchFrame = BrainstormIO.BstBatchTabFrame(im, eve, char(spontNames));
batchFrame.setVisible(1)

%% Setup Callbacks
% Generate images from Brainstorm
bstSpikeButton = GUI.CallbackInterface.batchRunSpikeAnalysis;
set(imagesBstButton, 'ActionPerformedCallback', {@brainstorm_runProcess, 'Images', mc})

bstBackgroundButton = GUI.CallbackInterface.batchRunBackgroundAnalysis;
set(bstBackgroundButton, 'ActionPerformedCallback', mc_bst_backgroundanalysis);


bstDipoleButton = GUI.CallbackInterface.batchRunDipoleViz;



    

