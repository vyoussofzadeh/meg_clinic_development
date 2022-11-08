function [Events, AcqPars, aveDescriptionFile] = ave_write_description(FileNames)
% write .ave file

% Parse the average file to get the event description and create the average
% description file
averageFile = fullfile(FileNames.filelocation, FileNames.aveName);
if ~exist(averageFile, 'file')
    error('Cannot find average SSS file');
end
[Events, AcqPars] = parse_aveFile_events(averageFile);
eveInfoFile = fullfile(FileNames.filelocation, [FileNames.protocol '_eventInfo.mat']);
save(eveInfoFile,'Events','AcqPars')

% Extract events according to event description
%extract_rawFile_events(Events, AcqPars);

% Write the off-line average desciption file
aveDescriptionFile = strcat(FileNames.filelocation, '/', FileNames.protocol,'.ave');

% Open file
fid = fopen(aveDescriptionFile,'w');
fprintf(fid,'%s\n%s\t%s\n%s\n%s\n', '#','#','Average Description File','#','average {');
fprintf(fid,'\t%s %s\n','name',FileNames.protocol);
fprintf(fid,'\t%s %s\n','outfile',[FileNames.filelocation '/' FileNames.cleanAveFileName]);
fprintf(fid,'\t%s %s\n','logfile',[FileNames.filelocation '/' FileNames.logAveFileName]);
fprintf(fid,'\t%s %s\n','eventfile',[FileNames.filelocation '/' FileNames.fxnlEvents]);

% First write Rejection Limits
fprintf(fid,'%s\n%s\t%s\n%s\n', '#','#','Rejection Limits','#');
fprintf(fid,'\t%s %s\n','stimIgnore',num2str(AcqPars.stimIgnore)); 
fprintf(fid,'\t%s %s\n','ecgReject',num2str(AcqPars.ecgReject));
fprintf(fid,'\t%s %s\n','eegReject',num2str(AcqPars.eegReject));
fprintf(fid,'\t%s %s\n','eogReject',num2str(AcqPars.eogReject));
fprintf(fid,'\t%s %s\n','eegFlat',num2str(AcqPars.eegFlat));
fprintf(fid,'\t%s %s\n','ecgFlat',num2str(AcqPars.ecgFlat));
fprintf(fid,'\t%s %s\n','eogFlat',num2str(AcqPars.eogFlat));
fprintf(fid,'\t%s %s\n','magReject',num2str(AcqPars.magReject));
fprintf(fid,'\t%s %s\n','gradReject',num2str(AcqPars.gradReject));

% Next write the categories
fprintf(fid,'%s\n%s\t%s\n%s\n', '#','#','Categories','#');

for n=1:AcqPars.nCategories
    
    fprintf(fid,'\t%s\n','category {');
    % Name
    fprintf(fid,'\t\t%s %s\n','name',Events(n).eventName);

    % Event
    fprintf(fid,'\t\t%s %s\n','event',num2str(Events(n).eventNewBits));
    
    % Start time
    fprintf(fid,'\t\t%s %s\n','tmin',num2str(Events(n).catStart));

    % End time
    fprintf(fid,'\t\t%s %s\n','tmax',num2str(Events(n).catEnd));

    fprintf(fid,'\t\t%s %s\n','bmin','-0.2');
    fprintf(fid,'\t\t%s %s\n','bmax','-0.005');
    fprintf(fid,'\t\t%s %s\n','ignore','0');
    fprintf(fid,'\t%s\n','}');    
    
end
fprintf(fid,'%s','}');

fclose(fid);




