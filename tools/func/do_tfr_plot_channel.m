function [time_of_interest,chan_of_interest, val] = do_tfr_plot_channel(cfg_main, tfr)

%%
% First compute the average over trials:
cfg = [];
chan_avg = ft_freqdescriptives(cfg, tfr);


if cfg_main.bslcorr == 1
    % And baseline-correct the average:
    cfg = [];
    cfg.baseline = [-0.3 0];
    cfg.baselinetype = 'db'; % Use decibel contrast here
    chan_avg_bsl = ft_freqbaseline(cfg, chan_avg);
    chan_avg_bsl.powspctrm(isnan(chan_avg_bsl.powspctrm))=0;
    meanpow = squeeze(nanmean(chan_avg_bsl.powspctrm, 2));
%     meanpow = squeeze(median(chan_avg_bsl.powspctrm, 1));
    %     meanpow = squeeze(nanstd(chan_avg_bsl.powspctrm, 1));
%     meanpow = squeeze(kurtosis(chan_avg_bsl.powspctrm));
    
else
    chan_avg.powspctrm(isnan(chan_avg.powspctrm))=0;
    meanpow = squeeze(nanmean(chan_avg.powspctrm, 2));
%     meanpow = squeeze(nanvar(chan_avg.powspctrm, 1));
%     Y = diff(chan_avg.powspctrm,1); meanpow = abs(squeeze(nanmean(Y, 1)));
%         meanpow = squeeze(median(chan_avg.powspctrm, 1));
%         meanpow = squeeze(nanstd(chan_avg.powspctrm, 1));
%     meanpow = squeeze(kurtosis(chan_avg.powspctrm));
end

% baseline = cfg_main.baseline;
% 
% % And baseline-correct the average:
% cfg = [];
% % cfg.baseline = [-0.3 0];
% cfg.baseline = baseline;
% cfg.baselinetype = 'db'; % Use decibel contrast here
% chan_avg_bsl = ft_freqbaseline(cfg, chan_avg);

% chan_avg_bsl.powspctrm(isnan(chan_avg_bsl.powspctrm))=0;
% meanpow = squeeze(mean(chan_avg_bsl.powspctrm, 1));

tim_interp = linspace(cfg_main.toi(1), cfg_main.toi(2), 512);
% chan_interp = linspace(1, cfg_main.fmax, 512);
chan_interp = 1:size(meanpow,1);

% We need to make a full time/frequency grid of both the original and
% interpolated coordinates. Matlab's meshgrid() does this for us:
[tim_grid_orig, chan_grid_orig] = meshgrid(tfr.time,1:size(meanpow,1));
[tim_grid_interp, chan_grid_interp] = meshgrid(tim_interp, chan_interp);

% And interpolate:
pow_interp = interp2(tim_grid_orig, chan_grid_orig, meanpow, tim_grid_interp, chan_grid_interp, 'spline');

%%
% while n==1
pow_interp1  = pow_interp;
tim_interp1  = tim_interp;
chan_interp1 = chan_interp;

%%
[~,idx] = min(pow_interp1(:));
[row,col] = ind2sub(size(pow_interp1),idx);

time_of_interest = tim_interp1(col);
chan_of_interest = chan_interp1(row);

timind = nearest(tim_interp, time_of_interest);
freqind = nearest(chan_interp, chan_of_interest);
pow_at_toi = pow_interp(:,timind);
pow_at_foi = pow_interp(freqind,:);

%%
val = [];
val.pow = pow_interp;
val.time = tim_interp;
val.freq = chan_interp;


% Plot figure
if cfg_main.plotflag == 1
    
    figure();
    ax_main  = axes('Position', [0.1 0.2 0.55 0.55]);
    ax_right = axes('Position', [0.7 0.2 0.1 0.55]);
    ax_top   = axes('Position', [0.1 0.8 0.55 0.1]);
    
    
    %%
    axes(ax_main);
    im_main = imagesc(tim_interp, chan_interp, pow_interp);
    % note we're storing a handle to the image im_main, needed later on
    xlim([cfg_main.toi(1), cfg_main.toi(2)]);
    axis xy;
    xlabel('Time (s)');
    ylabel('Chan/sensor');
    clim = max(abs(meanpow(:)));
    caxis([-clim clim]);
    % colormap(brewermap(256, '*RdYlBu'));
    hold on;
    plot(zeros(size(chan_interp)), chan_interp, 'k:');
    
    %%
    axes(ax_top);
    area(tim_interp, pow_at_foi,...
        'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
    xlim([cfg_main.toi(1), cfg_main.toi(2)]);
    ylim([-clim clim]);
    box off;
    ax_top.XTickLabel = [];
    ylabel('Power (dB)');
    hold on;
    plot([0 0], [-clim clim], 'k:');
    
    %%
    if ~isempty(cfg_main.title)
        title(cfg_main.title)
    end
    %%
    axes(ax_right);
    area(chan_interp, pow_at_toi,...
        'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
    view([270 90]); % this rotates the plot
    ax_right.YDir = 'reverse';
    ylim([-clim clim]);
    box off;
    ax_right.XTickLabel = [];
    ylabel('Power (dB)');
    
    %%
    h = colorbar(ax_main, 'manual', 'Position', [0.85 0.2 0.05 0.55]);
    ylabel(h, 'Power vs baseline (dB)');
    
    %%
    % Main plot:
    axes(ax_main);
    plot(ones(size(chan_interp))*time_of_interest, chan_interp,...
        'Color', [0 0 0 0.1], 'LineWidth', 3);
    plot(tim_interp, ones(size(tim_interp))*chan_of_interest,...
        'Color', [0 0 0 0.1], 'LineWidth', 3);
    
    % Marginals:
    axes(ax_top);
    plot([time_of_interest time_of_interest], [0 clim],...
        'Color', [0 0 0 0.1], 'LineWidth', 3);
    axes(ax_right);
    hold on;
    plot([chan_of_interest chan_of_interest], [0 clim],...
        'Color', [0 0 0 0.1], 'LineWidth', 3);
    
%     set(gcf, 'Position', [1000   100   1500   300]);

    
    %%
%     cfg = [];
%     cfg.baseline = [-0.3 0];
%     cfg.baselinetype = 'absolute';
%     chan_bsl = ft_freqbaseline(cfg, tfr);
%     
%     cfg = [];
%     cfg.variance = 'yes';
%     chan_sem = ft_freqdescriptives(cfg, chan_bsl);
%     
%     tscore = chan_sem.powspctrm./ chan_sem.powspctrmsem;
%     
%     % Average the t-score over our channels:
%     tscore = squeeze(mean(tscore, 1));
%     
%     tscore(isnan(tscore))=0;
%     
%     tscore_interp = interp2(tim_grid_orig, chan_grid_orig, tscore,...
%         tim_grid_interp, chan_grid_interp, 'spline');
%     
%     alpha = 0.01;
%     tcrit = tinv(1-alpha/2, size(tfr.powspctrm, 1)-1);
%     
%     opacity = abs(tscore_interp) / tcrit;
%     opacity(opacity > 1) = 1;
    
    if ~isempty(cfg_main.savefile)
        % hcp_write_figure([cfg_main.savefile,'.png'], gcf, 'resolution', 300);
        saveas(gcf,[cfg_main.savefile,'.png'])
    end
end
