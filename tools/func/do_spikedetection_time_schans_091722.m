function [time_occur, out_val] = do_spikedetection_time_schans(cfg, val)


% f_cfg          = [];
% f_cfg.hpfilter = 'yes';
% f_cfg.lpfilter = 'yes';
% f_cfg.hpfiltord = 3;
% f_cfg.hpfreq = 4;
% f_cfg.lpfreq = 40;
% f_data = ft_preprocessing(f_cfg, cln_data);

fs = cfg.fsample;

% val.pow = f_data.trial{1}(1,:);
% val.time = f_data.time{1}(1,:);


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
% [~, minidx1] = min(abs(val.freq - cfg.foi(1))); val.freq(minidx1);
% [~, minidx2] = min(abs(val.freq - cfg.foi(2))); val.freq(minidx2);

% data_in  = detrend(val.pow);
d_in = abs(smooth(val.pow));
d_in = abs(hilbert(d_in));
% d_in = rms(d_in);
d_in = zscore(d_in);

% ts_pp = (abs(hilbert(abs(data_in))));
% % ts_pp = ((hilbert(abs(val.pow(minidx1:minidx2,:)))));
% ts_pp = ts_pp./max(ts_pp(:));
%
% % ts_pp = (abs((val.pow(minidx1:minidx2,:))));
% % ts_pp = ts_pp./max(ts_pp(:));
%
% d_in = nanmean(ts_pp,1);
% d_in = smooth(d_in)';

% d_in = nanmedian(ts_pp,1);
% d_in = nanstd(ts_pp,1);
% d_in = kurtosis(ts_pp,1);
% d_in = nanvar(ts_pp,1);
% d_in = d_in - mean(d_in);

% figure,plot(d_in)

%%
% for i=1:length(ts_pp)
% [~, peaksample] = findpeaks(d_in, 'MinPeakDistance', 10); % peaks have to be separated by 300 sample points to be treated as separate
% end

%%
% addpath('/MEG_data/LAB_MEMBERS/Vahab/Github/MCW-MEGlab/FT/functions/External')
% tmp = detrend(val.pow(minidx1:minidx2,:));
% tmp = detrend(tmp);
% [thres_buf,env, bin] = envelop_hilbert_modified((tmp),20,2,20,0);
%
%
% thre = 0.8
% [~,b] = find(thres_buf > thre.*max(thres_buf));
% [~,initCross,finalCross,nextCross,midRef] =  dutycycle(bin);
% if isempty(initCross)
%     idx = find(bin > 0); ipoints = idx(1);
% else
%     max_idx = intersect(find(initCross < b(1)),find(finalCross > b(1)));
%     if isempty(max_idx)
%         max_idx = find(initCross < b(1));
%         max_idx = max_idx(end);
%     end
%     ipoints = round(initCross(max_idx));
% end

%%


%%
% thre_ok = 0;
% while thre_ok == 0
%     disp('enter the threshold level (e.g, 0.2):')
%     inp.thre = cfg.thre;

%%
thre = cfg.thre;
[mx, ~] = max(d_in(3:end));
peaksample  = d_in  > thre.*mx;
time_occur = val.time(peaksample);
out_val = d_in(peaksample);


diff(time_occur);
idx = find(diff(time_occur) > 3);
time_occur  = time_occur(idx+1);
out_val = out_val(idx+1);

%%

% thre = cfg.thre;
% [mx, ~] = max(d_in(3:end));
% peaksample  = d_in  > thre.*mx;
% time_occur = val.time(peaksample);
% out_val = d_in(peaksample);
% 
% k = 1;
% time_occur_sel = [];
% out_val_sel = [];
% if length(time_occur) > 2
%     time_occur = sort(time_occur, 'ascend');
%     for i= 1:length(time_occur)-1
%         df = time_occur(i+1) - time_occur(i);
%         if df > 5
%             time_occur_sel(k) = time_occur(i);
%             out_val_sel(k) = out_val(i);
%             k = k + 1;
%         end
%     end
% else
%     time_occur_sel  = time_occur;
% end
% 
% disp(time_occur_sel)
% time_occur = time_occur_sel;
% out_val = out_val_sel;


%% Time varying window
% w1 = val.time(1); l = 5; ov = l.*0.2; j=1; wi=[];
% %         w1 = 0.4; l = 0.8; ov = l.*0.2; j=1; wi=[];
% while w1+l < val.time(end)
%     wi(j,:) = [w1, w1+l]; j=j+1; w1 = w1 + ov;
% end
% 
% for i=1:length(wi)
%     [~, idx1] = min(abs(val.time - wi(i,1)));
%     [~, idx2] = min(abs(val.time - wi(i,2)));
%     sel_val = d_in(idx1:idx2);
%     sel_tim = val.time(idx1:idx2);
%     figure,plot(sel_tim, sel_val);
% %     [~, peaksample] = findpeaks(sel_val, 'MinPeakDistance', idx2-idx1-1); % peaks have to be separated by 300 sample points to be treated as separate
%     [~, peaksample] = max(sel_val); % peaks have to be separated by 300 sample points to be treated as separate
%     sel_time_occure = sel_tim(peaksample);
%     hold on
%     plot([sel_time_occure sel_time_occure],[min(sel_val), max(sel_val)],'-', 'Color',[0.7 0.7 0.7]);
%     pause,
% end


%%
% [~, peaksample] = findpeaks(d_in, 'MinPeakDistance', 50); % peaks have to be separated by 300 sample points to be treated as separate
% time_occur = val.time(peaksample);
% out_val = d_in(peaksample);
% idx = out_val > 0.1.*max(out_val);
% time_occur = time_occur(idx);
% out_val = out_val(idx);

%%
if cfg.plot == 1
    
    figure,plot(val.time, val.pow)
    set(gcf, 'Position', [800   500   1000   200]);
    
    figure,plot(val.time, d_in)
    for j=1:length(time_occur)
        hold on
        plot([time_occur(j) time_occur(j)],[min(d_in), max(d_in)],'-', 'Color',[0.7 0.7 0.7]);
        text(time_occur(j),out_val(j), num2str(j))
    end
    plot([val.time(1) val.time(end)],[thre.*mx, thre.*mx],'-', 'Color',[0.8 0.8 0.1]);
    title([cfg.ttl, ' (amp envelope), thre: ', num2str(thre),'.*max'])
    set(gcf, 'Position', [800   500   1000   200]);
    
    %     figure,
    %     subplot 211
    %     plot(val.time, mean(ts_pp,1)), xlabel('Time'),ylabel('mean pow');
    %     subplot 212
    %     plot(val.freq(minidx1:minidx2), mean(ts_pp,2)), xlabel('Freq'), ylabel('mean pow');
    
%     kk =  (cfg.foi(2) - cfg.foi(1))/10;
    
    %         figure, imagesc(val.time, val.freq, d_in);
    %         ylabel('Chans '); xlabel('Time (sec)')
    %         axis xy;
    %         %     for j=1:length(time_occur)
    %         %         hold on
    %         %         plot([time_occur(j) time_occur(j)],[cfg.foi(2)-kk, cfg.foi(2)],'-', 'Color',[1 1 1]);
    %         %         plot([time_occur(j) time_occur(j)],[cfg.foi(1), cfg.foi(1)+kk],'-', 'Color',[1 1 1]);
    %         %         text(time_occur(j),out_val(j), num2str(j))
    %         %     end
    %         title([cfg.ttl, ' (TFR), thre: ', num2str(thre),'.*max'])
    %         set(gcf, 'Position', [800   800   1000   200]);
    %     end
    % disp(time_occur)
    % disp('====')
    
    
    %     disp('OK with the threshold (yes:y, no:n)?')
    %     ask_thre_ok = input('','s');
    %     switch ask_thre_ok
    %         case 'y'
    %             thre_ok = 1;
    %         otherwise
    %             close all
    %     end
end
end
