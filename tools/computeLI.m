function LI = computeLI(tResultFile, zResultFile)
% This function would generate LI's indices for the quantification of the
% response to the language stimuli in the auditory definition naming task,
% in contrast with control sounds

% Project to colin27 brain
sSubject = bst_get('Subject', '@default_subject');
sSurface = sSubject.Surface;
iSurface = find(~cellfun(@isempty,strfind({sSurface.FileName}, '@default_subject/tess_bv_tcortex.mat')));
destSurfFile = sSurface(iSurface).FileName;

% t-test result
% if ~iscell(zResultFile)
%     tResultFile = cellstr(tResultFile);
% end
% bst_project_sources(tResultFile, destSurfFile, 1);

% z-score result
if ~iscell(zResultFile)
    zResultFile = cellstr(zResultFile);
end
bst_project_sources(zResultFile, destSurfFile, 1);
temp = regexp(char(zResultFile), '/', 'split');

% Get result filename and load ImageGridAmp into matlab
[sStudy, iStudy] = bst_get('Study', 'Group_analysis/@intra/brainstormstudy.mat');
iResult = find(~cellfun(@isempty,strfind({sStudy.Result.FileName}, temp{2})));
file = sStudy.Result(iResult).FileName;
sProtocolInfo = bst_get('ProtocolInfo');
fileToLoad = fullfile(sProtocolInfo.STUDIES,file);
sResult = load(fileToLoad);
ImageGridAmp = sResult.ImageGridAmp;

% Matt create the other scouts...
% Load the scout file(s)
scoutFile = fullfile(sProtocolInfo.SUBJECTS, '@default_subject/scout_LH_RH.mat');
sScout = load(scoutFile);
LHscout = sScout.Scout(1).Vertices;
RHscout = sScout.Scout(2).Vertices;

% time 0 = 300samples
t1 = 450;
t2 = 750;

LHvals = ImageGridAmp(LHscout,t1:t2);
maxVal = max(max(LHvals));
ind = find(LHvals > maxVal/3);
LH = length(ind);

RHvals = ImageGridAmp(RHscout,t1:t2);
maxVal = max(max(RHvals));
ind = find(RHvals > maxVal/3);
RH = length(ind);

LI = (LH-RH)/(LH+RH);

end