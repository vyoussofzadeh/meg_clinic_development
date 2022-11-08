function [time_occur, out_val] = do_spikedetection_time_schans(cfg, val)


fs = cfg.fsample;

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

% ft_progress('init', 'etf',     'Please wait...');
d_in = val.pow;
% d_in = (d_in - mean(d_in))./std(d_in);

pow_mean = [];
for i=1:length(wi)
%     ft_progress(i/length(wi), 'Processing windows (reading values) %d from %d', i, length(wi))  % show string, x=i/N
    
    [~, idx1] = min(abs(val.time - wi(i,1)));
    [~, idx2] = min(abs(val.time - wi(i,2)));
    
    sel_val = d_in(:,idx1:idx2);
    
    switch cfg.metric
        case 'mean'
            pow_mean(i) = nanmean(nanmean((abs(smooth(sel_val))),1));
        case 'var'
            pow_mean(i) = nanmean(var((((sel_val))),1));
        case 'std'
            pow_mean(i) = nanmean(std((((sel_val))),1));
        case 'rms'
            pow_mean(i) = nanmean(rms((((sel_val))),1));
        case 'skewness'
            pow_mean(i) = nanmean(skewness((((sel_val))),1));
        case 'ttest'
            [~,~,~,stats] = ttest(sel_val);
            pow_mean(i) = nanmean(stats.tstat);
    end
%         figure,plot(mean(sel_val,1));
end
% ft_progress('close')

%%
time_occur = [];
out_val = []; peaksample = [];
d_spk = pow_mean./max(pow_mean);
thre = cfg.thre;
[mx, ~] = max(d_spk);
peaksample  = find(d_spk  > thre.*mx ==1);
time_occur = wi(peaksample,:);
out_val = d_spk(peaksample);

% figure,bar(d_spk);
% for i=1:length(peaksample)
%     hold on
%     bar(peaksample(i),d_spk(peaksample(i)),'FaceColor','r');
% end
% set(gcf, 'Position', [800   500   1000   200]);

%%
% ft_progress('init', 'etf',     'Please wait...');
% d_in = val.pow;
time_occur_sel = [];
tre = 100;
for i=1:size(time_occur,1)
    %     ft_progress(i/length(time_occur), 'Checking corr against pca template %d from %d', i, length(time_occur))  % show string, x=i/N
    [~, idx1] = min(abs(val.time - time_occur(i,1)));
    [~, idx2] = min(abs(val.time - time_occur(i,2)));
    
    if idx2+tre < length(val.time) && idx1-tre > 1
        idx1 = idx1-tre;
        idx2 = idx2+tre;
    end
    sel_val = d_in(:,idx1:idx2);
    sel_tim = val.time(idx1:idx2);
    [~, mvar_idx] = max(((abs((sel_val)))));
    time_occur_sel(i) = sel_tim(mvar_idx);
end
time_occur = unique(time_occur_sel)';

%% removing nearby time-interval
time_occur1 = time_occur; tre = 0.3;
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
% d_in = val.pow ./max(val.pow);
tre = 100;
out_val_new = [];
for i=1:length(time_occur)
    [~, idx] = min(abs(val.time - time_occur(i)));
    if idx+tre < length(val.time) && idx-tre > 1
        out_val_new(i) = rms((d_in(idx-tre:idx+tre)));
    else
        out_val_new(i) = d_in(idx);
    end
end
out_val = out_val_new;

%%
if cfg.plot == 1    
    figure,
    plot(val.time, d_in)
    for j=1:length(time_occur)
        hold on
        plot([time_occur(j) time_occur(j)],[min(d_in(:)), max(d_in(:))],'-', 'Color',[0.7 0.7 0.7]);
    end
    title([cfg.ttl, ', ',cfg.metric,', thre: ', num2str(thre),'.*max'])
    set(gcf, 'Position', [800   500   1000   200]);
    
end
end
