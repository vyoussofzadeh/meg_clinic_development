function spikedetect(varargin)
% branstorm_callback: starts brainstorm
%
% USAGE:    brainstorm_callback
%
% INPUT:
%
% Author: Vahab Youssof Zadeh, 20202
% Update: 06/07/23

% --------------------------- Script History ------------------------------
% VY 11-Nov-2022 Creation
% -------------------------------------------------------------------------

flag.analysis = 'y';

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

logFile = GUI.MCLogFile;
FileNames = [];
mask = [];
stimSource=[];

clc, close all

%% Get selected file info
mc.setMessage(GUI.Config.M_READ_DATA_FILE);
try
    filename = char(mc.getInfo(GUI.Config.I_SELECTEDFILE));
catch
    GUI.ErrorMessage(GUI.ErrorMessage.WRONG_FILE_TYPE, 'SSS');
    return
end

% Selected file must an 'sss' file
index1 = strfind(filename,'_sss');
index2 = strfind(filename, '_tsss');
index3 = strfind(filename, '_cHPIsss');

if isempty(index1) && isempty(index2) && isempty(index3)
    GUI.ErrorMessage(GUI.ErrorMessage.WRONG_FILE_TYPE, 'SSS');
    return
end

filelocation = char(mc.getInfo(GUI.Config.I_FILE_LOCATION));
if strcmp(filelocation, 'null')
    GUI.ErrorMessage(GUI.ErrorMessage.FILE_LOCATION_NOT_FOUND, '');
    return
end

% Read configuration info
FileNames = create_default_file_names(filename);
FileNames.filelocation = filelocation;

% Find fxnl data
wf = GUI.DataSet.currentWorkflow;
FileNames.aveName = char(wf.getName(GUI.WorkflowConfig.AVESSS));
if strcmp(FileNames.aveName,'')
    % check for a raw ave file that has not been through sss
    files = dir(fullfile(char(GUI.DataSet.rawDataPath), FileNames.rawAveName));
    if isempty(files)
        FileNames = set_ave_description(FileNames, 'raw');
    else
        % ensure the STI channel gets preserved during the cleaning
        FileNames = set_ave_description(FileNames, 'functional');
    end
else
    FileNames = set_ave_description(FileNames, 'functional');
end

% Get workflow variables
mask = char(wf.getName(GUI.WorkflowConfig.MASK));
stimSource = char(wf.getName(GUI.WorkflowConfig.STIMSOURCE));

%% Check FieldTrip
if ~exist('ft_freqanalysis', 'file')
    %     ft_path ='/opt/matlab_toolboxes/ft_packages/latest/fieldtrip-master';
    ft_path ='/opt/matlab_toolboxes/ft_packages/Stable_version/fieldtrip-master';
    addpath(ft_path); ft_defaults
end

%%
ask = [];

clc
disp('Select modality (MEG:1, EEG:2)')
ask.modsel = input('');

disp('Select frequncy range (Hz)');
disp('1: Wideband 4-40');
disp('2: Slow-rate 1-5')
disp('3: High-rate 20-40');
disp('4: Other frequncy');
ask.freq_occur_sel = input(':');

switch ask.freq_occur_sel
    case 1
        foi = [4,40];
    case 2
        foi = [1,5];
    case 3
        foi = [25,40];
    case 4
        disp('enter range [f1,f2]Hz:'); freq_range_sel = input(':');
        foi = [freq_range_sel(1), freq_range_sel(2)];
end

%%
switch ask.modsel
    case 1
        cfg = []; cfg.layout = 'neuromag306mag.lay'; lay = ft_prepare_layout(cfg);
        
        cfg = []; cfg.dataset = filename;
        %         cfg.channel = {'megmag', 'meggrad','eog'};
        cfg.channel = {'meg','eog'};
        
        raw_data = ft_preprocessing(cfg);
        modal = 'meg*'; savemodal = 'meg';
        cutoff_val = 10;
    case 2
        
        load('neuromag_21_2.mat'); % eeg-layout
        cfg = []; cfg.layout = lay_21_neuromag2.lay ; lay = ft_prepare_layout(cfg);
        
        cfg = []; cfg.dataset = filename; cfg.channel = {'eeg', 'eog'};
        cfg.reref = 'yes'; cfg.refmethod = 'avg'; cfg.refchannel = 'all';
        raw_data = ft_preprocessing(cfg);
        modal = 'eeg*'; savemodal = 'eeg';
        cutoff_val = 5;
end

cfg = [];
cfg.resamplefs = 500;
rsm_data = ft_resampledata(cfg, raw_data);

%%
cfg = []; cfg.toilim = [rsm_data.time{:}(1*rsm_data.fsample),rsm_data.time{:}(end-1*rsm_data.fsample)];
trm_data = ft_redefinetrial(cfg,rsm_data); %trimming data

%%
cfg = [];
cfg.channel = modal;
cln_data = ft_selectdata(cfg,trm_data);
cln_data_full = rsm_data;

%%
if length(cln_data.label) > 50
    disp('spatial res?');
    disp('1:All sensors (slow)')
    disp('2: one-tenth of sensors (fast)')
    ask.sensres  = input('');
    sel_sens = 1:10:length(cln_data.label);
else
    sel_sens = 1:length(cln_data.label);   
end

%%
cfg = [];
cfg.channel = sel_sens;
cln_data = ft_selectdata(cfg,cln_data);

disp('rej artifact: (yes:y, no:n):?'); ask.rej_artifact  = input('','s');
aft = []; aft.eog = []; aft.jump = []; aft.rejseg = [];
switch ask.rej_artifact
    case 'y'
        % Reject segments
        % open the browser and page through the trials
        cfg = [];
        cfg.blocksize = cln_data.time{1}(end);
        cfg.viewmode =  'vertical'; %'butterfly';% 'vertical'; 'component'
        %         cfg.viewmode =  'butterfly'; %'butterfly';% 'vertical'; 'component'
        cfg.continuous = 'yes';
        cfg.axisfontsize = 7;
        cfg.fontsize = 7;
        cfg.preproc.demean = 'yes';
        cfg.position = [300   400   1500   400];
        cfg.channel = sel_sens;
        cfg.preproc.hpfilter = 'yes';
        cfg.preproc.hpfreq = 2;
        cfg.ylim = [min(cln_data.trial{1}(:)),max(cln_data.trial{1}(:))];
        artf = ft_databrowser(cfg, cln_data);
        artifact_badsegment = artf.artfctdef.visual.artifact;
        
        % Jump artifact
        cfg = [];
        cfg.artfctdef.zvalue.interactive = 'yes';
        cfg.continuous = 'yes';
        % channel selection, cutoff and padding
        cfg.artfctdef.zvalue.channel = [modal,'*'];
        cfg.artfctdef.zvalue.cutoff = cutoff_val;
        cfg.artfctdef.zvalue.trlpadding = 0;
        cfg.artfctdef.zvalue.artpadding = 0;
        cfg.artfctdef.zvalue.fltpadding = 0;
        [~, artifact_jump] = ft_artifact_zvalue(cfg,trm_data);
        
        % EOG
        cfg            = [];
        cfg.continuous = 'yes';
        % channel selection, cutoff and padding
        cfg.artfctdef.zvalue.channel     = 'EOG';
        cfg.artfctdef.zvalue.cutoff      = 12;
        cfg.artfctdef.zvalue.trlpadding  = 0;
        cfg.artfctdef.zvalue.artpadding  = 0.1;
        cfg.artfctdef.zvalue.fltpadding  = 0;
        % algorithmic parameters
        cfg.artfctdef.zvalue.bpfilter   = 'yes';
        cfg.artfctdef.zvalue.bpfilttype = 'but';
        cfg.artfctdef.zvalue.bpfreq     = [2 15];
        cfg.artfctdef.zvalue.bpfiltord  = 4;
        cfg.artfctdef.zvalue.hilbert    = 'yes';
        cfg.artfctdef.zvalue.interactive = 'yes';
        [~, artifact_EOG] = ft_artifact_zvalue(cfg,trm_data);
        
        %%
        Compen_val  = 500;
        artifact_EOG = [artifact_EOG(:,1)-Compen_val, artifact_EOG(:,1)+Compen_val];
        artifact_jump = [artifact_jump(:,1)-Compen_val, artifact_jump(:,1)+Compen_val];
        
        aft = []; aft.eog = artifact_EOG; aft.jump = artifact_jump; aft.rejseg = artifact_badsegment;
end

%% TFR analysis
while flag.analysis == 'y'
    
    disp('1) single-chan/sensor time domain (method1 - vy)')
    disp('2) single-chan/sensor time domain (method2 - MR)')
    disp('3) freq-based')
    disp('4) Deep learning')
    ask.mtd = input('');
    %     askmtd = 4;
    switch ask.freq_occur_sel
        case 1
            spktpye = 'TFR_wideband'; ttl = [savemodal, ' wideband'];
        case 2
            spktpye = 'TFR_sr'; ttl = [savemodal, ' slow-rate'];
        case 3
            spktpye = 'TFR_hr'; ttl = [savemodal, ' high-rate'];
        case 4
            spktpye = 'TFR_sel_band'; ttl = [savemodal, ' selected-rate'];
    end
    
    switch ask.mtd
        case 1
            
            cfg          = [];
            cfg.hpfilter = 'yes';
            cfg.lpfilter = 'yes';
            cfg.hpfiltord = 3;
            cfg.hpfreq = foi(1);
            cfg.lpfreq = foi(2);
            f_data = ft_preprocessing(cfg, cln_data);
            
            atime_occur_chn = []; aval_chn = [];
            cfg = []; cfg.plot = 2; cfg.art = aft;
            cfg.ttl = [savemodal, ' wideband'];
            cfg.fsample = f_data.fsample;
            cfg.thre = 0.3;
            cfg.overlap = 1-0.5; % 1-0.6 means 40% overlap
            cfg.windowlength = 0.3;
            cfg.tempcorr = 0.6; % pca template corr
            cfg.metric = 'rms'; % 'var', 'mean' 'std', 'rms', 'skewness', 'ttest'
            
            disp(['1) Windowlength (sec):',num2str(cfg.windowlength)])
            disp(['2) Ampl threshold (0-1):',num2str(cfg.thre)])
            disp(['3) Window overlap (0-1):', num2str(cfg.overlap)])
            disp(['4) Metrics:',num2str(cfg.metric)])
            disp(['5) Plotting (flag):',num2str(cfg.plot)])
            disp('Settings are OK, Yes=y, No:no (change it): '); ask.setchage  = input('','s');
            
            if  ask.setchage == 'n'
                disp('specify par to modify, 1:5: '); ask.spcpar  = input('');
                for i = ask.spcpar
                    switch i
                        case 1
                            disp(['set windowlength (default was, ', num2str(cfg.windowlength),')']); cfg.windowlength = input('');
                        case 2
                            disp(['set thre (default was, ', num2str(cfg.thre),')']); cfg.thre  = input('');
                        case 3
                            disp(['set overlap (default was, ', num2str(cfg.overlap),')']); cfg.overlap  = input('');
                        case 4
                            disp(['set metric (default was, ', num2str(cfg.metric),')']);
                            disp('Options are, mean, var, std, rms, skewness')
                            cfg.metric  = input('','s');
                        case 5
                            disp(['set plot flag value (default was, ', num2str(cfg.plot),')']); cfg.plot  = input('');
                    end
                end
            end
            
            for i=1:size(f_data.trial{1},1)
                disp([num2str(i),'/',num2str(length(f_data.label))])
                data_chn.pow = f_data.trial{1}(i,:);
                data_chn.time = f_data.time{1};
                [time_occur_chn, out_val] = do_spikedetection_time_schans(cfg, data_chn);
                atime_occur_chn = [atime_occur_chn; time_occur_chn];
                aval_chn = [aval_chn, out_val];
            end
            %             disp(sort(unique(round(atime_occur_chn,2))))
            time_occur = sort(unique(round(atime_occur_chn,2)));
            [~,I] = sort(atime_occur_chn); pow_occur = aval_chn(I);
            
            d_in = f_data.trial{1};
            time_occur_sel = []; pow_occur_new = [];
            tre = 500;
            for i=1:size(time_occur,1)
                [~, idx] = min(abs(data_chn.time - time_occur(i)));
                if idx+tre < length(data_chn.time) && idx-tre > 1
                    sel_val = d_in(:,idx-tre:idx+tre);
                    sel_tim = data_chn.time(idx-tre:idx+tre);
                    [~, mvar_idx] = max((rms(sel_val)));
                    time_occur_sel(i) = sel_tim(mvar_idx);
                    pow_occur_new(i) = max((rms(sel_val)));
                    %                 figure,plot(sel_tim,sel_val), hold on,
                    %                 plot([time_occur_sel(i) time_occur_sel(i)],[min(d_in(:)), max(d_in(:))],'-', 'Color',[0.7 0.7 0.7]);
                    %                 plot([time_occur1(i) time_occur1(i)],[min(d_in(:)), max(d_in(:))],'-', 'Color',[0.4 1 0.7]);
                    %                 disp(time_occur_sel(i))
                    %                 disp(time_occur1(i))
                    %                 pause,
                else
                    time_occur_sel(i) = time_occur(i);
                    pow_occur_new(i) = pow_occur(i);
                end
            end
            [time_occur, idx] = unique(time_occur_sel);
            pow_occur = pow_occur_new(idx);
            %
            
            k = 1;
            time_occur_sel = [];
            pow_occur_new = [];
            for i=1:length(time_occur)
                idx = find(abs(time_occur - time_occur(i)) < 1);
                if length(idx) > 1
                    [p_val, imax] = max(pow_occur(idx));
                    time_occur_sel(k) = time_occur(idx(imax));
                    pow_occur_new(i) = p_val;
                else
                    time_occur_sel(k) = time_occur(i);
                    pow_occur_new(i) =  pow_occur(i);
                end
                k=k+1;
            end
            [time_occur, idx] = unique(time_occur_sel);
            pow_occur = pow_occur_new(idx);
            
            [srt_pow_occur, idx] = sort(pow_occur,'descend');
            srt_time_occur = time_occur(idx);
            
            %%
            report = [];
            report.time_occur_num = 1:length(time_occur);
            report.srt_time_occur_num = report.time_occur_num(idx);
            report.time_occur = time_occur;
            report.srt_time_occur = srt_time_occur;
            report.pow_occur = pow_occur;
            report.srt_pow_occur = srt_pow_occur;
            
            tbl_time_occur_num = table(report.time_occur_num');
            tbl_time_occur_num.Properties.VariableNames{'Var1'} = 'number';
            
            tbl_srt_time_occur_num = table(report.srt_time_occur_num');
            tbl_srt_time_occur_num.Properties.VariableNames{'Var1'} = 'sorted_number';
            
            tbl_time_occur = table(report.time_occur');
            tbl_time_occur.Properties.VariableNames{'Var1'} = 'time_occur';
            
            tbl_srt_time_occur = table(report.srt_time_occur');
            tbl_srt_time_occur.Properties.VariableNames{'Var1'} = 'sorted_time_occur';
            
            tbl_pow_occur = table(report.pow_occur');
            tbl_pow_occur.Properties.VariableNames{'Var1'} = 'value_occur';
            
            tbl_srt_pow_occur = table(report.srt_pow_occur');
            tbl_srt_pow_occur.Properties.VariableNames{'Var1'} = 'sorted_value_occur';
            
            rbl_report = [tbl_time_occur_num, tbl_time_occur, tbl_pow_occur, ...
                tbl_srt_time_occur_num, tbl_srt_time_occur, tbl_srt_pow_occur];
            
            disp(rbl_report)
            
            if length(report.pow_occur) > 20
                disp(rbl_report(1:20,:))
                disp('first 20 are also shown!')
            end
            
        case 2
            
            data_in=cln_data.trial{1};% electrodesXtimesamples
            %Scale amplitudes to microvolts and femtotesla
            
            switch savemodal
                case 'eeg'
                    data_in=data_in*10^7;% raw data in units of 0.1 microvolts?
                case 'meg'
                    data_in=data_in*10^13;% raw data in units of 0.1 picotesla?
            end
            chlabels=cln_data.label;
            
            % Choose parameters of the detection
            cfg = [];
            cfg.dtype = savemodal;
            cfg.fs = cln_data.fsample;
            cfg.spikeband = [5 50];
            cfg.statswin = 2;%seconds over which local amlitude stats are estimated
            cfg.zthresh = 4;
            cfg.minterval = 0.2;% Seconds to skip ahead after any spike detection
            cfg.revspikes = 0;% if 1 visually review each detected spike
            
            disp(['1) spikeband:',num2str(cfg.spikeband)])
            disp(['2) statswin:',num2str(cfg.statswin)])
            disp(['3) zthresh:', num2str(cfg.zthresh)])
            disp(['4) minterval:',num2str(cfg.minterval)])
            disp(['5) revspikes:',num2str(cfg.revspikes)])
            disp('Settings are OK, Yes=y, No:no (change it): '); ask.setchage  = input('','s');
            
            if  ask.setchage == 'n'
                disp('specify par to modify, 1:5: '); ask.spcpar  = input('');
                for i = ask.spcpar
                    switch i
                        case 1
                            disp(['set spikeband (default was, ', num2str(cfg.spikeband),')']); cfg.spikeband = input('');
                        case 2
                            disp(['set statswin (default was, ', num2str(cfg.statswin),')']); cfg.statswin  = input('');
                        case 3
                            disp(['set zthresh (default was, ', num2str(cfg.zthresh),')']); cfg.zthresh  = input('');
                        case 4
                            disp(['set minterval (default was, ', num2str(cfg.minterval),')']); cfg.minterval  = input('');
                        case 5
                            disp(['set revspikes (default was, ', num2str(cfg.revspikes),')']); cfg.revspikes  = input('');
                    end
                end
            end
            
            %Detect spikes
            tic;
            [chspikes,allspikes] = detMEGspikes(data_in,chlabels,cfg);
            
            time_occur = unique(cln_data.time{1}(allspikes));
            k=1;
            if cfg.revspikes ==1
                figure,
                %plot detections
                [M,N] = size(chspikes.stimes);
                for ch = 1:M
                    chstimes = (nonzeros(chspikes.stimes(ch,:)))';
                    nchspikes = length(chstimes);
                    for sp = 1:nchspikes
                        spiket = chstimes(sp);
                        plot(data_in(ch,spiket-500:spiket+500));
                        title([string(chlabels(ch)){1}, ', t:', num2str(time_occur(k))]);
                        xlim([0 1000]);
                        k = k+1;
                        %                     xline(500);
                        %                     plot([time_occur(j) time_occur(j)],[min(d_in(:)), max(d_in(:))],'-', 'Color',[0.7 0.7 0.7]);
                        %ylim([-500 500]);
                        input('Hit return to proceed...');
                    end
                end
            end
            disp(time_occur')
        case 3
            cfg = [];
            cfg.output     = 'pow';
            cfg.channel    = 'all';
            cfg.method     = 'mtmconvol';
            cfg.method     = 'wavelet';
            %         cfg.taper      = 'hanning';
            if foi(2) - foi(1) < 10
                cfg.foi        = foi(1):1:foi(2);
            else
                cfg.foi        = foi(1):2:foi(2);
            end
            cfg.keeptrials = 'yes';
            cfg.t_ftimwin  = 3 ./ cfg.foi;
            cfg.tapsmofrq  = 0.8 * cfg.foi;
            cfg.toi        = cln_data.time{1}(1):0.05:cln_data.time{1}(end);
            tfr_data        = ft_freqanalysis(cfg, cln_data);
            
            cfg = []; cfg.savepath = 1; cfg.savefile = [];
            %     cfg.fmax = foi(2);
            cfg.toi = [tfr_data.time(1), tfr_data.time(end)];
            cfg.bslcorr = 2; cfg.plotflag = 2; cfg.title = modal;
            [~,~, tfr_val]    = do_tfr_plot(cfg, tfr_data);
            
            askplot =1;
            cfg = []; cfg.plot = askplot; cfg.art = aft; cfg.ttl = ttl;  cfg.foi = foi;
            cfg.fsample = cln_data.fsample;
            [time_occur, ~] = do_spikedetection_tfr(cfg, tfr_val);
            disp(time_occur')
            
            report = [];
            report.time_occur_num = 1:length(time_occur);
            %             report.srt_time_occur_num = report.time_occur_num(idx);
            report.time_occur = time_occur;
            %             report.srt_time_occur = srt_time_occur;
            %             report.pow_occur = pow_occur;
            %             report.srt_pow_occur = srt_pow_occur;
            
            tbl_time_occur_num = table(report.time_occur_num');
            tbl_time_occur_num.Properties.VariableNames{'Var1'} = 'number';
            
            tbl_srt_time_occur_num = table(report.time_occur_num');
            tbl_srt_time_occur_num.Properties.VariableNames{'Var1'} = 'sorted_number';
            
            tbl_time_occur = table(report.time_occur');
            tbl_time_occur.Properties.VariableNames{'Var1'} = 'time_occur';
            
            tbl_srt_time_occur = table(report.time_occur');
            tbl_srt_time_occur.Properties.VariableNames{'Var1'} = 'sorted_time_occur';
            
            tbl_pow_occur = table(report.time_occur');
            tbl_pow_occur.Properties.VariableNames{'Var1'} = 'value_occur';
            
            tbl_srt_pow_occur = table(report.time_occur');
            tbl_srt_pow_occur.Properties.VariableNames{'Var1'} = 'sorted_value_occur';
            
            rbl_report = [tbl_time_occur_num, tbl_time_occur, tbl_pow_occur, ...
                tbl_srt_time_occur_num, tbl_srt_time_occur, tbl_srt_pow_occur];
            
        case 4

           disp('test') 
    end
    
    %%
    Datalog.spktpye = [savemodal, spktpye];
    %     disp('  Time-points (sec) | value(%)')
    %     disp('   ---------  ------')
    %     disp(time_occur)
    %     disp(['n: ', num2str(length(time_occur))]);
    
    %%
    % Sensor activations
    kk = 0.5;
    un_time_occur = unique(time_occur);
    
    if ~isempty(un_time_occur)
        
        disp('Plot selected time-series: (yes:y, no:n):?'); ask.plot_timeseries  = input('','s');
        if ask.plot_timeseries == 'y'
            disp('Enter the number of time-series to plot:?'); ask.sel_timeseries  = input('');
            
            for i=1:length(ask.sel_timeseries)
                cfg = [];
                cfg.toilim = [un_time_occur(ask.sel_timeseries(i)) - kk,un_time_occur(ask.sel_timeseries(i)) + kk];
                data_spk = ft_redefinetrial(cfg, cln_data);
                
                cfg = [];
                cfg.blocksize = kk*2;
                cfg.viewmode =  'vertical'; %'butterfly';% 'vertical'; 'component'
                cfg.continuous = 'yes';
                cfg.axisfontsize = 7;
                cfg.fontsize = 7;
                cfg.preproc.demean = 'yes';
                cfg.position = [900   900   500   1500];
                ft_databrowser(cfg, data_spk);
                set(gcf,'name',num2str(ask.sel_timeseries(i)),'numbertitle','off')
                
                data_spk_avg = data_spk;
                data_spk_avg.avg = mean(data_spk.trial{1},2);
                cfg = [];
                cfg.baselinetype = 'absolute';
                cfg.layout = lay;
                figure; ft_topoplotTFR(cfg,data_spk_avg);
                set(gcf, 'Position', [1600   900   300   300]);
                set(gcf,'name',num2str(ask.sel_timeseries(i)),'numbertitle','off')
            end
        end
        Datalog.spktpye = [savemodal, spktpye];
        disp('  Time-points (sec) | value(%)')
        disp('   ---------  ------')
        %     disp([time_occur, 100.*val_occur])
        %         disp(time_occur)
        
        %%
        disp('Save events (yes:y, no:n):?')
        ask.savingevent_ask = input('','s');
        if ask.savingevent_ask == 'y'
            
            [pathstr, ~] = fileparts(filename);
            cd(pathstr)
            if exist('./event', 'file') == 0, mkdir('./event'), end
            
            hdr = ft_read_header(filename);
            fs = hdr.orig.sfreq;
            first_samp = double(hdr.orig.raw.first_samp);
            
            savefile  = ['evt_', date,'_',Datalog.spktpye,'.txt'];
            textfile = ['event/',savefile];
            fid=fopen(textfile,'w');
            event = [first_samp, first_samp/fs, 0, 0];
            fprintf(fid, '%d\t', event); % marker value
            fprintf(fid,'%6s %12s\n','test');
            for j=1:length(time_occur)
                event(j+1,1) = round(time_occur(j)*fs) + event(1,1);
                event(j+1,2) = time_occur(j) + event(1,2);
                event(j+1,3) = 0;
                event(j+1,4) = 5555;
                fprintf(fid,'\n');
                fprintf(fid, '%d\t', event(j+1,:)); % marker value
                fprintf(fid,'%6s %12s\n',Datalog.spktpye);
            end
            fclose(fid);true
            
            disp('Events for data,')
            disp(filename)
            disp('was saved at,')
            disp(pathstr)
            disp('as')
            disp(savefile)
            disp('You can review data and import events (.txt) using mne browse')
        end
    else
        disp('no spike was detected!');
    end
    
    %%
    if ask.modsel == 1
        disp('MEG source analysis (yes:y, no:n):');
        ask.soanalysis = input('','s');
        switch ask.soanalysis
            case 'y'
                cfg          = [];
                cfg.hpfilter = 'yes';
                cfg.lpfilter = 'yes';
                cfg.hpfiltord = 3;
                cfg.hpfreq = foi(1);
                cfg.lpfreq = foi(2);
                f_data_sel = ft_preprocessing(cfg, cln_data_full);
                %                 f_data_sel = cln_data_full;
                
                cfg = [];
                cfg.channel = 'meg';
                f_data_sel1 = ft_selectdata(cfg, f_data_sel);
                
                n_spk = 20;
                cfg = [];
                cfg.rbl_report  = rbl_report;
                cfg.n_spk = n_spk;
                cfg.kk = 0.5;
                [D_spk_apnd, cov_D_spk] = do_spkdata(cfg, f_data_sel1); % combine spike data
                
                disp(filename)
                cfg = [];
                cfg.iChannelsData = 1:length(cov_D_spk.label);
                [ftLeadfield, ftHeadmodel, ~, ~, ~, sourcemodel] = do_anat(cfg);
                
                cfg = [];
                cfg.ftLeadfield = ftLeadfield;
                cfg.headmodel   = ftHeadmodel;
                cfg.n_spk = 10; %n_spk;
                [D_source, D_source_all] = do_lcmv_source_segments(cfg, D_spk_apnd);
                D_source.kurtosis = mean(D_source_all,1)';
                D_source.kurtosis = rms(D_source_all);
                
                mask = 'kurtosis';
                
                cfg = []; cfg.mask = mask;
                D_source = do_normalize(cfg, D_source);
                
                cfg = []; cfg.mask = mask;
                cfg.sourcemodel = sourcemodel;
                cfg.D_source = D_source;
                do_surface_source_plot(cfg), title(cfg.mask);
                
                cfg = [];
                cfg.ftLeadfield = ftLeadfield;
                cfg.headmodel = ftHeadmodel;
                cfg.Connres = size(ftLeadfield.pos,1);
                cfg.foi = [4,7];
                do_source_conn_wPLI(cfg, D_spk_apnd)
                
                cfg = [];
                cfg.saveflag = 2;
                cfg.foilim = [2 100];
                cfg.plotflag  = 1;
                cfg.tapsmofrq = 8;
                cfg.taper     = 'hanning';
                do_fft(cfg, D_spk_apnd); title('psd raw')
                
                
                cfg = [];
                cfg.ftLeadfield = ftLeadfield;
                cfg.headmodel = ftHeadmodel;
                D_source = do_lcmv_source(cfg, cov_D_spk);
                
                cfg = []; cfg.mask = 'kurtosis';
                D_source = do_normalize(cfg, D_source);
                
                cfg = []; cfg.mask = mask;
                cfg.sourcemodel = sourcemodel;
                cfg.D_source = D_source;
                do_surface_source_plot(cfg), title(cfg.mask)
                
%                 cfg = [];
%                 cfg.ftLeadfield = ftLeadfield;
%                 cfg.headmodel = ftHeadmodel;
%                 cfg.Connres = size(ftLeadfield.pos,1);
%                 evt = do_source_conn(cfg, cov_D_spk);
%                 
%                 D_source.evt = evt;
%                 cfg = []; cfg.mask = 'evt';
%                 cfg.sourcemodel = sourcemodel;
%                 cfg.D_source = D_source;
%                 do_surface_source_plot(cfg), title(cfg.mask);
                
        end
    end
    
    %%
    disp('===')
    disp('Continue the data analysis (yes:y, no:n):');
    ask.dataanalysis = input('','s');
    if ask.dataanalysis == 'y'
        disp('Select frequncy range (Hz)');
        disp('1: Wideband 4-40');
        disp('2: Slow-rate 1-5')
        disp('3: High-rate 20-40');
        disp('4: Other frequncy');
        ask.freq_occur_sel = input(':');
        
        switch ask.freq_occur_sel
            case 1
                foi = [4,40];
            case 2
                foi = [1,5];
            case 3
                foi = [25,40];
            case 4
                disp('enter range [f1,f2]Hz: '); ask.freq_range_sel = input(':');
                foi = [ask.freq_range_sel(1), ask.freq_range_sel(2)];
        end
    else
        disp('end of analysis!')
        disp('Close figures (yes:y, no:n):');
        ask.closefig = input('','s');
        switch ask.closefig
            case {'y','Y'}
                close all
            otherwise
                return
        end
        disp('===')
        return,
    end
    
    %%
end
