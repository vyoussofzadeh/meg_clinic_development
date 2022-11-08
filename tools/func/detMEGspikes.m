function [chspikes,allspikes]=detMEGspikes(mydat,chlabels,cfg)
%Function detects candidate spike events in MEG/EEG data
%Adapted from detectpotentialspikes.m used for ECoG data (MR)

%Inputs:
%mydat is the MEG or EEG data Nchannels X Ntimesamples
%chlabels = string array with channel names
%minterval = minimum interval after a detercation before another detection
%zthresh=threshold in Z values, 
%If revspikes=1,plot detections to accept or reject with visual review
%minterval=minumum interval between events in seconds

%Outputs:
%chspikedat (NchannelsXNchevents) sample indices at spike peaks in each ch
%allspikedat (Nallevents)vector with sample indices of all spike events


% 09/15/2022   MR Wrote it
    
    %Size up the input
    [M,N]=size(mydat);%get number of channels timesamples
    dtype=cfg.dtype;
    fs=cfg.fs;
    sdur=N/fs;
    zthresh=cfg.zthresh;
    minterval=cfg.minterval;%seconds to skip ahead after any spike detection
    revspikes=cfg.revspikes;
    spikeband=cfg.spikeband;
    swin=fs*cfg.statswin;%number of samples over which local amplitude stats are estimated
    
    %Filter data
    fo=floor(5*fs/spikeband(1));%pick a filter order 5 periods of the lower freq in samples
    fprintf('Filtering %s data...\n',dtype);
    spikebanddat=ft_preproc_bandpassfilter(mydat,fs,spikeband,fo,'fir');
    absrootbanddat=sqrt(abs(spikebanddat));
    revband=[2 40];% band for visual review of spike & amplitude estimation
    revbanddat=ft_preproc_bandpassfilter(mydat,fs,revband,fo,'fir');
    
    scount=zeros([1 M]);
    allscount=0;
    sampsum=zeros([1 M]);
    stimes=[];
    allstimes=[];
    skends=round(swin/2);
    
    %First detect spikes independently on each channel
    fprintf('Detecting spikes in %s data....\n',dtype);
    for ii=1:M
        fprintf('Channel %d\n',ii);
        scount(ii)=0;
        jj=skends+1;%counter to advance down time samples
        while ((skends<jj) && (jj<N-skends))
            lmean=mean(absrootbanddat(ii,jj-skends:jj+skends));%get local mean
            lsd=sqrt(var(absrootbanddat(ii,jj-skends:jj+skends)));%get local Std Dev
            if ((absrootbanddat(ii,jj)-lmean)/lsd >zthresh)
                %Get max value of signal in a  200ms window centered around threshold crossing 
                winstart=jj-100; % start of search window
                winend=jj+100; % end of search window
                [~,wint]=max(absrootbanddat(ii,winstart:winend));% get index of maxima in search window
                spiket=winstart+wint;% gets index of the spike peak in the full data
                samp=peak2peak(revbanddat(ii,winstart:winend));% get the peak-to-trough spike amplitude
                if(revspikes)
                    subplot(2,1,1);
                    %define a window for plot
                    winstart=jj-round(skends/2); % start of spike window
                    winend=jj+round(skends/2); % end of spike window
                    plot(absrootbanddat(ii,winstart:winend));%review full epoch
                    title(string(chlabels(ii)));
                    xlim([0 skends]);
                    %ylim([-20 50]);
                    xline(round(skends/2));
                    subplot(2,1,2);
                    plot(revbanddat(ii,winstart:winend));%review full epoch
                    xlim([0 skends]);
                    xline(round(skends/2));
                    if strcmp(dtype,'eeg')
                        set(gca,'Ydir','reverse');
                    end
                    %ylim([-10 10]);
                    str=input('Accept spike? Hit-return to accept / n to reject...','s');
                    if (isempty(str))
                        %increment spike counter at ch ii & record corresponding sample index spiket @ the peak
                        scount(ii)=scount(ii)+1;
                        stimes(ii,scount(ii))=spiket;
                        allscount=allscount+1;
                        allstimes(allscount)=spiket;%just record the time --we sort this later
                        sampsum(ii)=sampsum(ii)+samp;%summate spike peak amplitudes at ch ii
                        jj=jj+floor(fs*minterval);
                    end
                elseif(~revspikes)
                    scount(ii)=scount(ii)+1;
                    stimes(ii,scount(ii))=spiket;
                    allscount=allscount+1;
                    allstimes(allscount)=spiket;%just record the time --we sort this later
                    sampsum(ii)=sampsum(ii)+samp;%summate spike peak amplitudes at ch ii
                    sampsum(ii)=sampsum(ii)+samp;%summate spike peak-to-trough amplitudes
                    jj=jj+floor(fs*minterval);
                else
                    jj=jj+1;
                end%end of optional visual confirmation
            else
                jj=jj+1;
            end %End of conditional statement following a threshold crossing
        end %end of while loop
    end%end of for loop over ii (Channels)

    if(revspikes)
        close;
    end
    
    % Assign the output quantities
    chspikes=[];
    allspikes=[];
    chspikes.stimes=stimes;
    chspikes.srates=(scount./sdur)*3600;%get spikesrate/hour
    chspikes.amps=sampsum./scount;% div element-by-element to get mean amps
    allspikes=sort(allstimes);
        
    fprintf('\n');
    for ii=1:M
        fprintf('Detected %d spikes in Channel %s\n',scount(ii),string(chlabels(ii)));
        if(isnan(chspikes.amps(ii)))
            chspikes.amps(ii)=0.0;
        end
    end

end %function end
