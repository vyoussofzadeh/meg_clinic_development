function log_file_name = close_study(varargin)

if isempty(varargin)
    studyDirectory = pwd;
else
    studyDirectory = varargin{1};
end

log_file_name = fullfile(studyDirectory, 'study_closed.log');
fid = fopen(log_file_name,'a+');
fprintf(fid, sprintf('\n%s\n',date));

% find all _sss.fif files in the study directory
[files,bytes,names]=dirr(studyDirectory, 'sss.fif','name');

% list files in the log file
if isempty(names)
    fprintf(fid, 'No files found')
else
    s = [];
    for j = 1:length(names)
        s=sprintf('%s\n',[s char(names(j))]);
    end
    fprintf(fid, sprintf('%s\n','Found the following files:'))
    fprintf(fid,sprintf('%s\n',s));
    resp = questdlg(sprintf('%s\n%s','Would you like to delete the following files?',s)); 
    if strcmp(resp,'Yes')    
        for i=1:length(names)
            if ~isempty(strfind(names(i), 'sss.fif'))
                try
                    delete(char(names(i)))
                    fprintf(fid, sprintf('%s\n',['Deleted file: ' char(names(i))]));
                catch ME
                    fprintf(fid, sprintf('%s\n',['Cannot delete file: ' char(names(i))]));
                end
            end
        end
    end
end
fclose(fid)