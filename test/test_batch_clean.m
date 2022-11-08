% This script is designed to test megclinic
% Just run this script 4 times
% 1.  Delete all files except the original raw
% 2.  Delete all the clean files and leave only the sss files
% 3.  Delete the final clean raw and average files
% 4.  Do not delete any files - just run on completed directory

testDir = '/MEG_data/test/megclinic_demo/100303';
runDir1 = 'Run02_lefthandmovementtovisualcue';
runDir2 = 'run01_spont';


meg_clinic('clean', testDir);
meg_clinic('clean', testDir, 'ongoing')