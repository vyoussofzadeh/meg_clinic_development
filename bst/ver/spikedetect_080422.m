function spikedetect(varargin)
% branstorm_callback: starts brainstorm
%
% USAGE:    brainstorm_callback
%
% INPUT:
%
% Author: Vahab Youssof Zadeh, 20202
% Update: 07/27/22
% --------------------------- Script History ------------------------------
% EB 20-JULY-2022 Creation
% -------------------------------------------------------------------------

flag.analysis = 1;

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

%% Apply Time-freq analysis
if ~exist('ft_freqanalysis', 'file')
    ft_path = '/usr/local/MATLAB_Tools/fieldtrip_20190419';
    addpath(ft_path); ft_defaults
    addpath('/usr/local/MATLAB_Tools/fieldtrip_20190419/external/mne')
    %     error('Add fieldtrip to path!')
    
%     addpath('/MEG_data/LAB_MEMBERS/Vahab/Github/tools/ft_packages/fieldtrip_master')
%     ft_defaults
end

%%
ask = [];

clc
disp('Select modality (MEG:1, EEG:2)')
ask.modsel = input('');

disp('Select frequncy range (Hz)');
disp('1: Wideband 4-40');
disp('2: Slow-rate 1-5')
disp('3: High-rate 25-40');
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
        cfg.channel = {'megmag', 'meggrad','eog'};
        
        raw_data = ft_preprocessing(cfg);
        modal = 'meg';
        cutoff_val = 10;
    case 2
        
        load('neuromag_21_2.mat');
        cfg = []; cfg.layout = lay_21_neuromag2.lay ; lay = ft_prepare_layout(cfg);
        
        cfg = []; cfg.dataset = filename; cfg.channel = {'eeg', 'eog'};
        cfg.reref = 'yes'; cfg.refmethod = 'avg'; cfg.refchannel = 'all';
        raw_data = ft_preprocessing(cfg);
        modal = 'eeg';
        cutoff_val = 5;
end

%
cfg = [];
cfg.resamplefs = 500;
rsm_data = ft_resampledata(cfg, raw_data);

cfg = []; cfg.toilim = [rsm_data.time{:}(10*rsm_data.fsample),rsm_data.time{:}(end-10*rsm_data.fsample)];
trm_data = ft_redefinetrial(cfg,rsm_data); %trimmed data

%%
cfg = []; cfg.toilim = [rsm_data.time{:}(10*rsm_data.fsample),rsm_data.time{:}(end-10*rsm_data.fsample)];
trm_data = ft_redefinetrial(cfg,rsm_data); %trimmed data

%% Jump artifact

trm_data1 = trm_data;
trm_data1.trial{1} = abs(trm_data1.trial{1});

cfg = [];
cfg.artfctdef.zvalue.interactive = 'yes';
cfg.continuous = 'yes';
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = [modal,'*'];
cfg.artfctdef.zvalue.cutoff = cutoff_val;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;
% cfg.artfctdef.zvalue.hilbert       = 'yes';
cfg.artfctdef.zvalue.rectify       = 'yes';
[cfg, artifact_jump] = ft_artifact_zvalue(cfg,trm_data);

%%
cfg = [];
cfg.continuous = 'yes';
cfg.artfctdef.jump.medianfilter  = 'yes';
cfg.artfctdef.jump.medianfiltord = 9;
cfg.artfctdef.jump.absdiff       = 'yes';
cfg.artfctdef.jump.channel       = [modal,'*'];
cfg.artfctdef.jump.cutoff        = cutoff_val;
cfg.artfctdef.jump.trlpadding    = 0;
cfg.artfctdef.jump.artpadding    = 0;
[cfg, artifact_jump] = ft_artifact_jump(cfg, trm_data)

%% EOG
cfg            = [];
cfg.continuous = 'yes';
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = 'EOG';
cfg.artfctdef.zvalue.cutoff      = 4;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;
cfg.artfctdef.zvalue.fltpadding  = 0;
% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter   = 'yes';
cfg.artfctdef.zvalue.bpfilttype = 'but';
cfg.artfctdef.zvalue.bpfreq     = [2 15];
cfg.artfctdef.zvalue.bpfiltord  = 4;
cfg.artfctdef.zvalue.hilbert    = 'yes';
% feedback
cfg.artfctdef.zvalue.interactive = 'no';
[~, artifact_EOG] = ft_artifact_zvalue(cfg,trm_data);

%%
cfg = [];
cfg.artfctdef.reject = 'value'; %'partial'; %'complete'; %'value'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
% cfg.continuous = 'yes';
cfg.artfctdef.eog.artifact = artifact_EOG; %
cfg.artfctdef.jump.artifact = artifact_jump;
% cfg.artfctdef.value = 0;
% cfg.artfctdef.muscle.artifact = artifact_muscle;
trm_nar = ft_rejectartifact(cfg,trm_data);
%%

cfg = [];
cfg.continuous = 'yes';
cfg.artfctdef.jump.medianfilter  = 'yes';
cfg.artfctdef.jump.medianfiltord = 9;
cfg.artfctdef.jump.absdiff       = 'yes';
cfg.artfctdef.jump.channel       = [modal,'*'];
cfg.artfctdef.jump.cutoff        = cutoff_val;
cfg.artfctdef.jump.trlpadding    = 0;
cfg.artfctdef.jump.artpadding    = 0;
[cfg, artifact_jump] = ft_artifact_jump(cfg, trm_nar)

%% EOG
cfg            = [];
cfg.continuous = 'yes';
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = 'EOG';
cfg.artfctdef.zvalue.cutoff      = 4;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;
cfg.artfctdef.zvalue.fltpadding  = 0;
% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter   = 'yes';
cfg.artfctdef.zvalue.bpfilttype = 'but';
cfg.artfctdef.zvalue.bpfreq     = [2 15];
cfg.artfctdef.zvalue.bpfiltord  = 4;
cfg.artfctdef.zvalue.hilbert    = 'yes';
% feedback
cfg.artfctdef.zvalue.interactive = 'no';
[~, artifact_EOG] = ft_artifact_zvalue(cfg,trm_nar);

cfg = [];
cfg.artfctdef.reject = 'value'; %'partial'; %'complete'; %'value'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
% cfg.continuous = 'yes';
cfg.artfctdef.eog.artifact = artifact_EOG; %
cfg.artfctdef.jump.artifact = artifact_jump;
% cfg.artfctdef.value = 0;
% cfg.artfctdef.muscle.artifact = artifact_muscle;
trm_nar2 = ft_rejectartifact(cfg,trm_nar);

%%
for i=1:size(trm_nar2.trial{1},1)
    trm_nar2.trial{1}(i,:) = fillmissing(trm_nar2.trial{1}(i,:),'previous');
end

%%
cfg = [];
cfg.channel = modal;
cln_data = ft_selectdata(cfg,trm_nar2);

% inspecting cleaned data
cfg             = [];
cfg.continuous  = 'yes';
cfg.viewmode    = 'vertical'; % all channels seperate
cfg.blocksize   = 30;         % view the continous data in 30-s blocks
ft_databrowser(cfg, cln_data);

%% ICA
% disp('ICA analysis: (1:Y, 0:N):?'); ask.run_ica  = input('');
% 
% if ask.run_ica ==1    
%     cfg            = [];
%     cfg.method     = 'runica';
%     cfg.numcomponent = 20;       % specify the component(s) that should be plotted
%     comp           = ft_componentanalysis(cfg, trm_nar2);
%     
% 
% 
%     cfg = [];
%     cfg.viewmode = 'component';
%     cfg.layout = lay;
%     ft_databrowser(cfg, comp);
%     
%     cfg              = [];
%     cfg.output       = 'pow';
%     cfg.channel      = 'all';%compute the power spectrum in all ICs
%     cfg.method       = 'mtmfft';
%     cfg.taper        = 'hanning';
%     cfg.foi          = 2:2:30;
%     freq = ft_freqanalysis(cfg, comp);
%     
%     n = 20;
%     nby1 = 5; nby2 = 4;
%     
%     Nfigs = ceil(size(comp.topo,1)/n);
%     tot = Nfigs*n;
%     
%     rptvect = 1:size(comp.topo,1);
%     rptvect = padarray(rptvect, [0 tot-size(comp.topo,1)], 0,'post');
%     rptvect = reshape(rptvect,n,Nfigs)';
%     
%     figure
%     for r=1:n
%         cfg=[];
%         cfg.channel = rptvect(:,r);
%         subplot(nby1,nby2,r);set(gca,'color','none');
%         ft_singleplotER(cfg,freq);
%     end
%     set(gcf, 'Position', [800   600   800   500]);
%     
%     cfg = [];
%     disp('Select bad ICs:')
%     ask.bic = input('');
%     cfg.component = comp.label(ask.bic);
%     cfg.updatesens = 'no';
%     cln_data = ft_rejectcomponent(cfg, comp, trm_nar2);
% else
%     cln_data = trm_nar2;
% end

%%
% addpath('/MEG_data/LAB_MEMBERS/Vahab/Github/MCW-MEGlab/MCW_MEGlab_git/FT_fucntions/functions_new')
% MaxFreq = 40;
% disp(['max freq was set to, ', num2str(MaxFreq), 'Hz'])
% disp('for editing see, Line 119 in spikedetect.m')

%% TFR analysis
while flag.analysis == 1
    
    cfg = [];
    cfg.output     = 'pow';
    cfg.channel    = 'all';
    cfg.method     = 'mtmconvol';
    cfg.taper      = 'hanning';
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
    cfg.fmax = foi(2);
    cfg.toi = [tfr_data.time(1), tfr_data.time(end)];
    cfg.bslcorr = 2; cfg.plotflag = 2; cfg.title = modal;
    [~,~, tfr_val]    = do_tfr_plot(cfg, tfr_data);    

    
    %%
    %     Run_sensorlist
    %     cfg = [];
    %     cfg.channel = Vertex;      tfr_ver = ft_selectdata(cfg, tfr_data); % vertex
    %     cfg.channel = Left_temp;   tfr_ltemp = ft_selectdata(cfg, tfr_data); % L-temporal
    %     cfg.channel = Right_temp;  tfr_rtemp = ft_selectdata(cfg, tfr_data); % R-temporal
    %     cfg.channel = Left_pari;   tfr_lpri = ft_selectdata(cfg, tfr_data); % l-prietal
    %     cfg.channel = Right_pari;  tfr_rpri = ft_selectdata(cfg, tfr_data); % r-prietal
    %     cfg.channel = left_occi;   tfr_locci = ft_selectdata(cfg, tfr_data); % l-occipital
    %     cfg.channel = right_occi;  tfr_rocci = ft_selectdata(cfg, tfr_data); % r-occipital
    %     cfg.channel = left_front;  tfr_lfront = ft_selectdata(cfg, tfr_data); % l-frontal
    %     cfg.channel = right_front; tfr_rfront = ft_selectdata(cfg, tfr_data); % r-frontal
    %
    %     cfg = [];
    %     cfg.savepath = 1;
    %     cfg.savefile = [];
    %     cfg.fmax = 40;
    %     cfg.toi = [tfr_ver.time(1), tfr_ver.time(end)];
    %     cfg.bslcorr = 2; cfg.plotflag = 2;
    %
    %     cfg.title = [];
    %     [~,~, val_ver]    = do_tfr_plot(cfg, tfr_ver);
    %     [~,~, val_ltemp]  = do_tfr_plot(cfg, tfr_ltemp);
    %     [~,~, val_rtemp]  = do_tfr_plot(cfg, tfr_rtemp);
    %     [~,~, val_lpri]   = do_tfr_plot(cfg, tfr_lpri);
    %     [~,~, val_rpri]   = do_tfr_plot(cfg, tfr_rpri);
    %     [~,~, val_locci]  = do_tfr_plot(cfg, tfr_locci);
    %     [~,~, val_rocci]  = do_tfr_plot(cfg, tfr_rocci);
    %     [~,~, val_lfront] = do_tfr_plot(cfg, tfr_lfront);
    %     [time_of_interest,freq_of_interest, val_rfront] = do_tfr_plot(cfg, tfr_rfront);
    
    %%
    % disp('Show TFR maps (1:Y, 0:N):?')
    % askplot = input(': ');
    askplot =1;
    switch ask.freq_occur_sel
        case 1
            cfg = []; cfg.plot = askplot; cfg.foi = [4,40];  cfg.ttl = [modal, ' wideband'];
            [time_occur_bb, val_occur_bb] = do_spikedetection_tfr(cfg, tfr_val);
            time_occur = time_occur_bb'; val_occur = val_occur_bb'; spktpye = 'TFR_wideband';
        case 2
            cfg = []; cfg.plot = askplot; cfg.foi = [1,5];   cfg.ttl = [modal, ' slow-rate'];
            [time_occur_sr, val_occur_sr] = do_spikedetection_tfr(cfg, tfr_val);
            time_occur = time_occur_sr'; val_occur = val_occur_sr'; spktpye = 'TFR_sr';
        case 3
            cfg = []; cfg.plot = askplot; cfg.foi = [25,40]; cfg.ttl = [modal, 'high-rate'];
            [time_occur_hr, val_occur_hr] = do_spikedetection_tfr(cfg, tfr_val);
            time_occur =time_occur_hr'; val_occur = val_occur_hr'; spktpye = 'TFR_hr';
        case 4
            cfg = []; cfg.plot = askplot; cfg.foi = [foi(1),foi(2)];
            cfg.ttl = [modal, ' selected-rate'];
            [time_occur_sl, val_occur_sl] = do_spikedetection_tfr(cfg, tfr_val);
            time_occur = time_occur_sl'; val_occur = val_occur_sl'; spktpye = 'TFR_sel_band';
    end
    
    %%
    Datalog.spktpye = [modal, spktpye];
    disp('  Time-points (sec) | value(%)')
    disp('   ---------  ------')
    disp([time_occur, 100.*val_occur])
    
    %%
    % Sensor activations
    kk = 0.5;
    un_time_occur = unique(time_occur);
    
    disp('Plot selected time-series: (1:Y, 0:N):?'); ask.plot_timeseries  = input('');
    if ask.plot_timeseries ==1
        disp('Enter the number of time-series to plot:?'); ask.sel_timeseries  = input('');
        
        for i=1:length(ask.sel_timeseries)
            cfg = [];
            cfg.toilim = [un_time_occur(ask.sel_timeseries(i)) - kk,un_time_occur(ask.sel_timeseries(i)) + kk];
            data_spk = ft_redefinetrial(cfg, cln_data);
            
            cfg = [];
            cfg.blocksize = kk*2;
            cfg.viewmode =  'vertical'; %'butterfly';% 'vertical'; 'component'
            cfg.continuous = 'yes';
%             cfg.preproc.demean  = 'yes';
%             cfg.preproc.detrend = 'yes';
%             cfg.fontsize = 0.01;
            cfg.axisfontsize = 8;
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
    Datalog.spktpye = [modal, spktpye];
    disp('  Time-points (sec) | value(%)')
    disp('   ---------  ------')
    disp([time_occur, 100.*val_occur])
    
    %% Reject and re-eval
    %     disp('Reject: (1:Y, 0:N):?'); ask.reject_peakedtm  = input('');
    %     if ask.reject_peakedtm ==1
    %         disp('Enter the number of time-series to reject:?'); ask.sel_rejtm  = input('');
    %
    %         cfg = [];
    %         cfg.toilim = [un_time_occur(ask.sel_timeseries(i)) - kk,un_time_occur(ask.sel_timeseries(i)) + kk];
    %         data_spk = ft_redefinetrial(cfg, trm_data);
    %     end
    
    %%
    disp('Save events (1:Y, 0:N):?')
    ask.savingevent_ask = input('');
    if ask.savingevent_ask ==1
        
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
    disp('===')
    disp('Continue the data analysis (1:Y, 0:N):');
    ask.dataanalysis = input('');
    if ask.dataanalysis == 1
        disp('Select frequncy range (Hz)');
        disp('1: Wideband 4-40');
        disp('2: Slow-rate 1-5')
        disp('3: High-rate 25-40');
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
        disp('===')
        return,
    end
end