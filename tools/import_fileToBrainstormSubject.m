file = '/MEG_data/helm/04f2_volunteer/101012/sss/run01_empty_rooom_upright/run01_empty_rooom_upright_raw_sss.fif';
subjectName = '04f2_volunteer';

[sSubject, iSubject] = bst_get('SubjectWithName', subjectName);

ImportOptions = db_template('ImportOptions');
        
% Open FIF file
AutoAnswer = 1;
sFile = in_fopen_fif(file, [], AutoAnswer, 'ignore');
% Close file
fclose(sFile.fid);

ImportOptions.ImportMode = 'Time';
ImportOptions.UseEvents = 0;
ImportOptions.TimeRange = sFile.prop.times;
ImportOptions.GetAllEpochs = 0;
ImportOptions.SplitRaw = 1;
ImportOptions.SplitLength = 2;
ImportOptions.UseSsp = 1;
ImportOptions.RemoveBaseline = 'all';
ImportOptions.AutoAnswer = 1;

% Import recordings
import_data(sFile, 'FIF', [], iSubject, ImportOptions);