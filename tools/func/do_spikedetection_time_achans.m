function time_occur = do_spikedetection_time_achans(cfg, f_data)


% f_cfg          = [];
% f_cfg.hpfilter = 'yes';
% f_cfg.lpfilter = 'yes';
% f_cfg.hpfiltord = 3;
% f_cfg.hpfreq = 4;
% f_cfg.lpfreq = 40;
% f_data = ft_preprocessing(f_cfg, cln_data);

fs = cfg.fsample;

val = [];
val.pow = f_data.trial{1};
val.time = f_data.time{1}(1,:);

%%
% sens = sensorlist();

%%
% disp([cfg.art.eog./fs])
% disp([cfg.art.jump./fs])
for i=1:size(cfg.art.eog,1)
    [~, idx1] = min(abs(val.time - cfg.art.eog(i,1)/fs));
    [~, idx2] = min(abs(val.time - cfg.art.eog(i,2)/fs));
    val.pow(:,idx1:idx2) = nan;
end
for i=1:size(cfg.art.jump,1)
    [~, idx1] = min(abs(val.time - cfg.art.jump(i,1)/fs));
    [~, idx2] = min(abs(val.time - cfg.art.jump(i,2)/fs));
    val.pow(:,idx1:idx2) = nan;
end
for i=1:size(cfg.art.rejseg,1)
    [~, idx1] = min(abs(val.time - cfg.art.rejseg(i,1)/fs));
    [~, idx2] = min(abs(val.time - cfg.art.rejseg(i,2)/fs));
    val.pow(:,idx1:idx2) = nan;
end

%%
disp(['1) windowlength:',num2str(cfg.windowlength)])
disp(['2) thre:',num2str(cfg.thre)])
disp(['3) overlap:', num2str(cfg.overlap)])
disp(['4) metric:',num2str(cfg.metric)])
disp(['5) PCAtemplate_corr:',num2str(cfg.tempcorr)])
disp('settings are OK, yes=y, no:no (change it): '); ask.setchage  = input('','s');

if  ask.setchage == 'n'
    disp('specify par to modify, 1:5: '); ask.spcpar  = input('');
    for i = ask.spcpar
        switch i
            case 1
                disp(['set windowlength (default was, ', num2str(cfg.windowlength),')']); cfg.windowlength  = input('');
            case 2
                disp(['set thre (default was, ', num2str(cfg.thre),')']); cfg.thre  = input('');
            case 3
                disp(['set overlap (default was, ', num2str(cfg.overlap),')']); cfg.overlap  = input('');
            case 4
                disp(['set metric (default was, ', num2str(cfg.metric),')']);
                disp('Options are, mean, var, std, rms, skewness')
                cfg.metric  = input('','s');
            case 5
                disp(['set pca template corr threshold (default was, ', num2str(cfg.tempcorr),')']); cfg.tempcorr  = input('');
        end
    end
end

%% Time varying window
overlap = 1-cfg.overlap;
if overlap ~=1
    w1 = val.time(1); l = cfg.windowlength; ov = l.*overlap; j=1; wi=[];
else
    w1 = val.time(1); l = cfg.windowlength; ov = l; j=1; wi=[];
end

while w1+l < val.time(end)
    wi(j,:) = [w1, w1+l]; j=j+1; w1 = w1 + ov;
end

ft_progress('init', 'etf',     'Please wait...');
d_in = val.pow;

% mu = mean(d_in(:)); sigma = std(d_in(:));
% d_in1 = (d_in - mu)./sigma; 

pow_mean = [];
for i=1:length(wi)
    ft_progress(i/length(wi), 'Processing windows (reading values) %d from %d', i, length(wi))  % show string, x=i/N
    
    [~, idx1] = min(abs(val.time - wi(i,1)));
    [~, idx2] = min(abs(val.time - wi(i,2)));
    
    sel_val = d_in(:,idx1:idx2);
    %     sel_tim = val.time(idx1:idx2);
    
    switch cfg.metric
        case 'mean'
            pow_mean(i) = mean(mean((abs(smooth(sel_val))),1));
        case 'var'
            pow_mean(i) = mean(var((((sel_val))),1));
        case 'std'
            pow_mean(i) = mean(std((((sel_val))),1));
        case 'rms'
            pow_mean(i) = mean(rms((((sel_val))),1));
        case 'skewness'
            pow_mean(i) = mean(skewness((abs((sel_val))),1));
        case 'ttest'
            [~,~,~,stats] = ttest(sel_val);
            pow_mean(i) = mean(stats.tstat);
    end
    %     figure,plot(sel_tim, mean(sel_val,1));
end
ft_progress('close')

%%
% [~, peaksample] = findpeaks(pow_mean, 'MinPeakDistance', 20); % peaks have to be separated by 300 sample points to be treated as separate
%
% [vv, I] = sort(pow_mean,'descend');
% wi(I(1:20),:)
% out_val = pow_mean(peaksample);
%
% figure, plot(pow_mean)
% for j=1:length(peaksample)
%     hold on
%     plot([peaksample(j) peaksample(j)],[min(pow_mean), max(pow_mean)],'-', 'Color',[0.7 0.7 0.7]);
%     text(peaksample(j),out_val(j), num2str(j))
% end
% % plot([val.time(1) val.time(end)],[thre.*mx, thre.*mx],'-', 'Color',[0.8 0.8 0.1]);
% % title([cfg.ttl, ' (amp envelope), thre: ', num2str(thre),'.*max'])
% set(gcf, 'Position', [800   500   1000   200]);

%%
time_occur = [];
out_val = []; peaksample = [];
d_spk = pow_mean./max(pow_mean);
thre = cfg.thre;
[mx, ~] = max(d_spk);
peaksample  = find(d_spk  > thre.*mx ==1);
time_occur = wi(peaksample,:);
out_val = d_spk(peaksample);

% ask.okrthre = 'n';
% if length(time_occur) > 50
%     while ask.okrthre == 'n'
%         disp(['num of time occurance:' num2str(length(time_occur))])
%         disp('raise threshold?, yes=y: '); ask.rthre  = input('','s');
%         if  ask.rthre == 'y'
%             disp('enter new threshold (>0.3)? '); thre  = input('');
%             [mx, ~] = max(d_in);
%             peaksample  = find(d_in  > thre.*mx ==1);
%             time_occur = wi(peaksample,:);
%             out_val = d_in(peaksample);
%             disp(['num of time occurance:', num2str(length(time_occur))]);
%             disp('Looking good?, yes:y, no:n: '); ask.okrthre = input('','s');
%         end
%     end
% end

% d_in1 = abs(hilbert(d_in));
% figure,plot(wi(:,1),smooth(smooth(d_in1)));

% time_occur = wi;

%%
% time_occur = [];
% % [~, peaksample] = findpeaks(d_spk); % peaks have to be separated by 300 sample points to be treated as separate
% [~, peaksample] = findpeaks(d_spk, 'MinPeakDistance', 10); % peaks have to be separated by 300 sample points to be treated as separate
% time_occur = wi(peaksample,:);

%% Template
% close all
ft_progress('init', 'etf',     'Please wait...');
d_in = val.pow;
comp = [];
for i=1:length(time_occur)
    %     disp([num2str(i), '/', num2str(length(time_occur))])
    ft_progress(i/length(time_occur), 'Processing thresholded time windows %d from %d', i, length(time_occur))  % show string, x=i/N
    
    [~, idx1] = min(abs(val.time - time_occur(i,1)));
    [~, idx2] = min(abs(val.time - time_occur(i,2)));
    sel_val = d_in(:,idx1:idx2);
    sel_tim = val.time(idx1:idx2);
    pca_val = do_pca(sel_val, 1);
    comp(i,:) = smooth(smooth(pca_val));
    %     comp(i,:) = (smooth(pca_val));
    
    %     figure(1), clf
    %     plot(sel_tim, sel_val./max(sel_val(:)));
    %     hold on
    %     plot(sel_tim, comp(i,:),'LineWidth',3)
    %     pause,
    
    % Conn analysis
    %     connout = do_conn(sel_val); evc(i) = mean(eigenvector_centrality_und(connout));
    %     figure, bar(evc)
    %     pause
end
ft_progress('close')

mcomp = mean(comp,1);
% mcomp = (mcomp-mean(mcomp))/std(mcomp);
[p,~,mu] = polyfit(1:length(mcomp),mcomp, 20);
f = polyval(p,1:length(mcomp),[],mu);

% figure, plot(mean(comp,1)),
% hold on
% plot(1:length(mcomp),f), title('PCA template')
% legend({'pca','polyfit'})

% k = polyder(p)
% ps = poly2sym(p)
% - x^20/1250 + (7*x^19)/5000 + (123*x^18)/10000 - (203*x^17)/10000 - (769*x^16)/10000 + (153*x^15)/1250 + (1329*x^14)/5000 - (503*x^13)/1250 - (2781*x^12)/5000 + (7839*x^11)/10000 + (901*x^10)/1250 - (581*x^9)/625 - (1379*x^8)/2500 + (851*x^7)/1250 + (453*x^6)/2500 - (3431*x^5)/10000 + (753*x^4)/10000 + (1763*x^3)/10000 - (179*x^2)/2000 - (761*x)/10000 + 107/10000

% save('spkpca_temp','f')
disp('use saved pca template, yes=y: ');
% ask.stempask  = input('','s');
ask.stempask = 'n';
switch  ask.stempask
    case 'y'
        load('spkpca_temp','f');
        %         load('spk_temp_ft','f');
end

% [P1,f1] = periodogram(mcomp,[],[],fs,'power');
% figure, plot(f1,P1)

%%
% close all
ft_progress('init', 'etf',     'Please wait...');

d_in = val.pow;
time_occur_sel = [];
cr_val = [];
for i=1:length(time_occur)
    %     disp([num2str(i), '/', num2str(length(time_occur))])
    ft_progress(i/length(time_occur), 'Checking corr against pca template %d from %d', i, length(time_occur))  % show string, x=i/N
    
    [~, idx1] = min(abs(val.time - time_occur(i,1)));
    [~, idx2] = min(abs(val.time - time_occur(i,2)));
    sel_val = d_in(:,idx1:idx2);
    sel_tim = val.time(idx1:idx2);
    pca_val = do_pca(sel_val, 1);
    
    %     cr_val(i) = corr2(abs(pca_val),abs(f));
    cr_val(i) = corr2((pca_val),(f));
    %     comp(i,:) = smooth(pca_val);
    
    
    % figure, plot(var((abs((sel_val)))))
    [~, mvar_idx] = max(var((abs((sel_val)))));
    time_occur_sel(i) = sel_tim(mvar_idx);
    %     disp(time_occur_sel(i))
    %     pause,
    
    %     if time_occur_sel(i) - time_occur_sel(i-1) < 0.2
    %     end
    
    %     figure(1), clf
    %     vall = sel_val./max(sel_val(:));
    %     plot(sel_tim, vall);
    %     hold on
    %     plot(sel_tim, comp(i,:),'LineWidth',3)
    %     plot([sel_tim(mvar_idx) sel_tim(mvar_idx)],[min(vall(:)), max(vall(:))],'-', 'Color',[0.7 0.7 0.7]);
    %     pause,
    
end
cr_idx  = abs(cr_val)  > cfg.tempcorr;
time_occur = unique(time_occur_sel(cr_idx))';


%% removing nearby time-interval
time_occur1 = time_occur;
tre = 0.3;
idx = find(diff(time_occur1) < tre);
time_occur_sel = time_occur1;
while ~isempty(idx)
    for i=1:length(idx)
        [~, idx1] = min(abs(val.time - time_occur1(idx(i))));
        [~, idx2] = min(abs(val.time - time_occur1(idx(i)+1)));
        [mvar1, ~] = max(var((abs((d_in(:,idx1))))));
        [mvar2, ~] = max(var((abs((d_in(:,idx2))))));
        
        if mvar1 > mvar2
            time_occur_sel(idx(i)) = time_occur1(idx(i));
            time_occur_sel(idx(i)+1) = time_occur1(idx(i));
        else
            time_occur_sel(idx(i)) = time_occur1(idx(i)+1);
            time_occur_sel(idx(i)+1) = time_occur1(idx(i)+1);
        end
    end
    time_occur_sel = unique(time_occur_sel);
    idx = find(diff(time_occur_sel) < tre);
    time_occur1 = time_occur_sel;
end
time_occur  =  unique(time_occur_sel);

%%
if cfg.plot == 1
    
    %         close all
    %         figure,
    %         plot(d_in(1,:))
    %         for j=1:length(time_occur)
    %             hold on
    %             plot([time_occur(j) time_occur(j)],[min(d_in(:)), max(d_in(:))],'-', 'Color',[0.7 0.7 0.7]);
    %             text(time_occur(j),out_val(j), num2str(j))
    %         end
    %         plot([0 length(d_in)],[thre.*mx, thre.*mx],'-', 'Color',[0.8 0.8 0.1]);
    %         title([cfg.ttl, ' (amp envelope), thre: ', num2str(thre),'.*max'])
    %         set(gcf, 'Position', [800   500   1000   200]);
    
    % figure, plot(cr_val)
    if cfg.tempcorr > 0
        tt = linspace(0,cfg.windowlength,length(mean(comp,1)));
        figure, plot(tt,f), title('PCA template '); xlabel('ms')
        set(gcf, 'Position', [800   800   400   200]);
    end
    %     hold on
    %     plot(1:length(mcomp),f), title('PCA template and modelled pca ')
    
    %     tm = mean(wi,2);
    % %     figure,plot(tm,smooth(smooth(d_spk)));
    %     figure,plot(tm,((d_spk)));
    %     hold on
    %     set(gcf, 'Position', [800   800   1200   200]); title('spike activity (across time windows)');
    %     plot([tm(1) tm(end)],[thre.*mx, thre.*mx],'-', 'Color',[0.8 0.8 0.1]);
    %     xlabel('mean time windows (sec)')
    %     ylabel([cfg.metric, ' (normalized)'])
    %     mtm = mean(time_occur,2);
    %     for j=1:length(mtm)
    %         plot([mtm(j) mtm(j)],[min(d_spk(:)), max(d_spk(:))],'-', 'Color',[0.7 0.7 0.7]);
    %         text(mtm(j),d_spk(j), num2str(j))
    %     end
    
    %     figure, bar(abs(cr_val))
    %     % xticklabels(round(time_occur_sel))
    %     set(gca,'Xtick', 1:length(time_occur_sel),'XtickLabel',(time_occur_sel));
    %     set(gca,'FontSize',8,'XTickLabelRotation',90);
    %     set(gcf, 'Position', [1000   100   1500   300]);
    %     set(gca,'color','none');
    
end
end
