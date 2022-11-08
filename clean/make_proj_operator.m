function make_proj_operator(directory, raw, eve, type)
% make_proj_operator: create ssp vectors and save to a file
%
% USAGE:    make_proj_operator(directory, raw, eve, type)   for making projections from an event file
%           make_proj_operator(directory, raw, [], type)    for making projections over entire file
%
% INPUT:    directory = location of the files
%           raw = name of the file to use for creating projections
%           eve = name of the event file
%           type = [ECG, ONGOING] type of projections to create
%
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009  Creation
% -------------------------------------------------------------------------
logFile = GUI.MCLogFile;
config = ArtifactClean.CleanConfig;

switch (type)
    case 'ECG'
        if strfind(raw, '_raw_sss')
            projTag = strcat('_raw_sss',char(config.ECG_PROJ));
        else
            projTag = char(config.ECG_PROJ);
        end
        start = char(config.ECG_TMIN);
        stop = char(config.ECG_TMAX);
        nMag = char(config.ECG_NMAG);
        nGrad = char(config.ECG_NGRAD);
        filterOn = config.INCLUDE_ECG_FILTERING;

        if filterOn
            hpf = char(config.ECG_HPFILTER);
            lpf = char(config.ECG_LPFILTER);
            command = ['mne_process_raw --cd ' directory ' --raw ' raw ' --events ' eve ' --makeproj --projtmin ' start ' --projtmax ' stop ' --saveprojtag ' projTag ' --projnmag ' nMag ' --projngrad ' nGrad ' --projevent 999 --highpass ' hpf ' --lowpass ' lpf ' --digtrigmask 0'];
            logFile.write(['command: ' command]);
            [status,w] = unix(command);
            logFile.write(w);
            %disp(w)
        else     
            command = ['mne_process_raw --cd ' directory ' --raw ' raw ' --events ' eve ' --makeproj --projtmin ' start ' --projtmax ' stop ' --saveprojtag ' projTag ' --projnmag ' nMag ' --projngrad ' nGrad ' --projevent 999 --filteroff --digtrigmask 0'];
            logFile.write(['command: ' command]);
            [status,w] = unix(command);
            logFile.write(w);
            %disp(w)            

        end

        %  For names containing DefaultHead_sss
        if strfind(raw, '_defaultHead_sss.fif')
            projFileName = strrep(raw, '_defaultHead_sss.fif', '_defaultHead_raw_sss_ecg-proj.fif');
            if exist(projFileName, 'file')
                newProjFileName = strrep(projFileName, '_defaultHead_raw_sss_ecg-proj.fif', '_defaultHead_sss_ecg-proj.fif');
                movefile(projFileName, newProjFileName);
            end
        end
        
    case 'ONGOING'
        projTag = strcat('_raw_sss',char(config.ONGOING_PROJ));
        nMag = char(config.ONGOING_NMAG);
        nGrad = char(config.ONGOING_NGRAD);
        filterOn = config.INCLUDE_OG_FILTERING;
        
        if filterOn
            hpf = char(config.OG_HPFILTER);
            lpf = char(config.OG_LPFILTER);
            command = ['mne_process_raw --cd ' directory ' --raw ' raw ' --makeproj --saveprojtag ' projTag ' --projnmag ' nMag ' --projngrad ' nGrad ' --highpass ' hpf ' --lowpass ' lpf ' --digtrigmask 0 --projgradrej -1 --projmagrej -1'];
            logFile.write(['command: ' command]);
            [status,w] = unix(command);
            logFile.write(w);
            %disp(w)
        else            
            command = ['mne_process_raw --cd ' directory ' --raw ' raw ' --makeproj --saveprojtag ' projTag ' --projnmag ' nMag ' --projngrad ' nGrad ' --filteroff --digtrigmask 0 -projgradrej -1 -projmagrej -1'];
            logFile.write(['command: ' command]);
            [status,w] = unix(command);
            logFile.write(w);
            %disp(w)
        end
        
    case 'EOG'
        if strfind(raw, '_raw_sss')
            projTag = strcat('_raw_sss',char(config.EOG_PROJ));
        else
            projTag = char(config.EOG_PROJ);
        end
        start = char(config.EOG_TMIN);
        stop = char(config.EOG_TMAX);
        nMag = char(config.EOG_NMAG);
        nGrad = char(config.EOG_NGRAD);
        filterOn = config.INCLUDE_EOG_FILTERING;
        
        events = mne_read_events(fullfile(directory,eve));
        eventNo = mode(double(events(:,3)));
        
        if filterOn
            hpf = char(config.EOG_HPFILTER);
            lpf = char(config.EOG_LPFILTER);
            command = ['mne_process_raw --cd ' directory ' --raw ' raw ' --events ' eve ' --makeproj --projtmin ' start ' --projtmax ' stop ' --saveprojtag ' projTag ' --projnmag ' nMag ' --projngrad ' nGrad ' --projevent ' num2str(eventNo) ' --highpass ' hpf ' --lowpass ' lpf ' --digtrigmask 0'];
            logFile.write(['command: ' command]);
            [status,w] = unix(command);
            logFile.write(w);
            %disp(w)
        else     
            command = ['mne_process_raw --cd ' directory ' --raw ' raw ' --events ' eve ' --makeproj --projtmin ' start ' --projtmax ' stop ' --saveprojtag ' projTag ' --projnmag ' nMag ' --projngrad ' nGrad ' --projevent ' num2str(eventNo) ' --filteroff --digtrigmask 0'];
            logFile.write(['command: ' command]);
            [status,w] = unix(command);
            logFile.write(w);
            %disp(w)            

        end

        %  For names containing DefaultHead_sss
        if strfind(raw, '_defaultHead_sss.fif')
            projFileName = strrep(raw, '_defaultHead_sss.fif', '_defaultHead_raw_sss_ecg-proj.fif');
            if exist(projFileName, 'file')
                newProjFileName = strrep(projFileName, '_defaultHead_raw_sss_ecg-proj.fif', '_defaultHead_sss_ecg-proj.fif');
                movefile(projFileName, newProjFileName);
            end
        end
        
end

    


