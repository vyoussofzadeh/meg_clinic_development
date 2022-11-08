function varargout = process_spect_decomp2( varargin )
% PROCESS_SPECT_DECOMP: Computes power in multiple, standard frequency bands

% @=============================================================================
% This software is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
%
% Copyright (c)2000-2010 Brainstorm by the University of Southern California
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html.
%
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Authors: Francois Tadel, Sylvain Baillet, 2010

macro_methodcall;
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = '[Experimental] Spectral decomposition and statistics';
sProcess.FileTag     = [];
sProcess.Description = ['<HTML>Computes power in multiple, standard frequency bands.<BR>' ...
    'Yields average, standard deviation and t-statistics across samples.<BR>' ...
    'WARNING: Only applies to KERNEL source files.'];
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Analyze';
sProcess.Index       = 504;
% Definition of the input accepted by this process
sProcess.InputTypes  = {'results'};
sProcess.OutputTypes = {[]};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
% === FREQUENCY BANDS
sProcess.options.freqbands.Comment = 'Frequency bands';
sProcess.options.freqbands.Type    = 'freqbands';
sProcess.options.freqbands.Value   = bst_get('DefaultFreqBands');
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end


%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>
% Get options
freqbands = sProcess.options.freqbands.Value;
OutputFiles = {};
ProtocolInfo = bst_get('ProtocolInfo');
% Progress bar
bst_progress('start', 'Computing Spectral Maps', 'Initialization...', 0, length(sInputs));

% Determine how many Studies are involved
[uniqueStudies, whichStudies, whichStudies2] = unique([sInputs(:).iStudy]);
nStudies = length(uniqueStudies);
kStudy = 0;
combineAllStudies = 1;
for iStudy = uniqueStudies
    kStudy = kStudy+1;
    % Get output study
    %iStudy =sInputs(1).iStudy ;
    sStudy = bst_get('Study',iStudy);
    OutputPath = fullfile(ProtocolInfo.STUDIES, fileparts(sStudy.FileName));
    %OutputPath = fullfile(ProtocolInfo.STUDIES, fileparts(sStudy.FileName));

    % Process all the files
    inoise = []; % Index of noisy input segments
    if combineAllStudies % Group all inputs in single spectral analysis (i.e. different runs, same subject)
        whichStudies = find(whichStudies2);
        try 
            if iStudy == uniqueStudies(2); % all computation done: Quit loop
                break
            end
        catch
        end
        
    else
        whichStudies = find(whichStudies2==kStudy);
    end
    
    nbSamplesA = length(whichStudies);
    
    for iInput = 1:nbSamplesA
        % Progress bar
        bst_progress('text', ['File: ' sInputs(whichStudies(iInput)).FileName]);
        bst_progress('inc', 1);

        % === READ FILES ===
        % Read results file
        kernelMat = in_bst_results(sInputs(whichStudies(iInput)).FileName, 0);
        disp(kernelMat.DataFile)
        if isempty(kernelMat.DataFile) || isempty(kernelMat.ImagingKernel)
            error('This process can be applied only to inversion kernel + recordings.');
        end
        if iInput == 1
            clear normd_FRMS low_vs_high_freq_contrastMap
            F_RMS = zeros(size(kernelMat.ImagingKernel,1), size(freqbands,1), nbSamplesA);
        end
        % Load recordings file
        dataMat = in_bst_data(kernelMat.DataFile, 'Time', 'F');
        % Select only channels used for source estimation
        F = dataMat.F(kernelMat.GoodChannel, :);
        Time = dataMat.Time;
        clear dataMat;

        % === ??? ===
        sRate = abs(1 / (Time(2) - Time(1)));
        nTime = length(Time);
        NFFT = 2^nextpow2(nTime); % Next power of 2 from length of y

        % ===================================================================
        % ==== TODO =========================================================

        % === Check for bad-trials ===
        dataTMP = bst_bandpass_fft(F(3:3:end,:),...
            sRate, 4,sRate/3);

        %figure, plot(dataTMP')
        %dataTMP = dataTMP - repmat(mean(dataTMP,2),1,size(dataTMP,2));
        maxAmp = max(abs(dataTMP(:)));
        tmpDiff = diff(dataTMP,1,2);
        %         meanDiffAmp = mean(mean(abs(tmpDiff)));
        %         stdDiffAmp = mean(std(tmpDiff,[],2));
        maxDiffAmp = max(abs(tmpDiff(:))); clear tmpDiff
        % minAmp = min(dataTMP(:));

        % Peak-to-peak trial rejection criterion
        if maxAmp > 4500e-15 || maxDiffAmp > 2500e-15 % magnetometers only; was 2500e-15
            sprintf('Data segment\n %s \n contains noisy data (%3.2f): skipping', (kernelMat.DataFile), maxAmp*1e15)
            inoise = [inoise, iInput];
            if ~exist('hnoise', 'var')
                hnoise = figure;
            else
                figure(hnoise)
            end
            plot(dataTMP')
            title(sprintf('Skipped %d trial(s)/epoch(s) out of %d', length(inoise),nbSamplesA))
            continue
        end

        %         % === Check for bad-trials ===
        %         dataTMP = bst_bandpass(F(3:3:end),...
        %             sRate, 4,sRate/3);
        %
        %         %figure, plot(dataTMP')
        %         %dataTMP = dataTMP - repmat(mean(dataTMP,2),1,size(dataTMP,2));
        %         maxAmp = max(dataTMP(:));
        %         % minAmp = min(dataTMP(:));
        %
        %         % Peak-to-peak trial rejection criterion
        %         if maxAmp > 2500e-15 % magnetometers only; was 2500e-15
        %             sprintf('Data segment\n %s \n contains noisy data (%3.2f): skipping', (kernelMat.DataFile), maxAmp*1e15)
        %             inoise = inoise+1;
        %             if ~exist('hnoise', 'var')
        %                 hnoise = figure;
        %             else
        %                 figure(hnoise)
        %             end
        %             plot(dataTMP')
        %             title(sprintf('Skipped %d trial(s)/epoch(s) out of %d', inoise,nbSamplesA))
        %             continue
        %         end

        % ===================================================================

        freqVec = sRate/2*linspace(0,1,NFFT/2);
        freqVec = freqVec(freqVec>0); % Do not consider DC of signal

        fftF = fft( repmat(hamming( size(F,2) )', size(F,1),1) .* F,NFFT,2)/nTime;
        %fftF = fft( F,NFFT,2)/nTime;
        %fftF = fftF(:,2:end); % Don't include DC in computation of power
        %powfftF = 2*abs(fftF(:,1:end/2));

        for ifreq = 1:size(freqbands,1)
            VecInd  = bst_closest([freqbands{ifreq,2:3}],freqVec);
            %F = bst_bandpass(F,sRate,freqBands(ifreq,1),freqBands(ifreq,2));
            F_RMS(:,ifreq,iInput) = sum(2*abs(kernelMat.ImagingKernel *  fftF(:, VecInd(1):VecInd(2))),2)...
                /length(VecInd(1):VecInd(2));
            % ImageGridAmp = sqrt(sum(ImageGridAmp.^2,2)/size(ImageGridAmp,2)); % compute root mean square power in current frequency band

            %Store unit scaled version of source RMS at each frequency for
            %subsequent computation of constrast maps
            normd_FRMS(:,ifreq) =  F_RMS(:,ifreq,iInput) / max( F_RMS(:,ifreq,iInput));
        end
        % Contrast maps of power at lower-higher frequency ranges
        try
            low_vs_high_freq_contrastMap(:,iInput) = (4* sum(normd_FRMS(:,1:3),2) - 3 *sum(normd_FRMS(:,5:end),2) ) ./ ...
                (4 * sum(normd_FRMS(:,1:3),2) + 3 *sum(normd_FRMS(:,5:end),2) );
        catch
        end

    end

    clear fftF

    % Compute statistics
    % Keep only good trials
    iGoodTrials = setdiff(1:nbSamplesA, inoise);
    nGoodTrials = length(iGoodTrials);
    try
        low_vs_high_freq_contrastMap = low_vs_high_freq_contrastMap(:,iGoodTrials);
    catch
    end
    
    
    F_RMS = F_RMS(:,:,iGoodTrials); % 15002x1x16
    aveStat = mean(F_RMS,3);
    stdStat = std(F_RMS,0,3);
    burstStat = max(abs(F_RMS),[],3)./(mean(F_RMS,3)+eps*min(abs(F_RMS(:))));
    varStat= var(F_RMS,0,3);  % added JL
    FanoF=varStat./aveStat; % added JL
    
    clear F_RMS

    CV = stdStat./aveStat;
    % Loop on frequency bands
    for ifreq = 1:size(freqbands,1)
        current_aveStat = aveStat(:,ifreq);
        current_stdStat = stdStat(:,ifreq);
        current_burstStat = burstStat(:,ifreq);  % JL 02262015: uncommented this line
        cvStat = CV(:,ifreq);
        FanoFStat=FanoF(:,ifreq); % added JL

   
        % === SAVE RESULTS ===
        % Erase some fields from the initial file
        kernelMat.ImagingKernel = [];
        kernelMat.DataFile      = [];
        kernelMat.navg = nGoodTrials;
        
        if 1
            % Save files
            SaveResults(repmat(current_stdStat./sum(stdStat,1),1,2), 'scaledSTD', ...
                sprintf('scaled STD: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials)); % JL 02192015: sum(stdStat,2) was changed to sum(stdStat,1)
            SaveResults(repmat(current_aveStat./sum(aveStat,1),1,2), 'scaledGAVE', ...
                sprintf('scaled GAVE: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials)); % JL 02192015: sum(aveStat,2) was changed to sum(aveStat,1)
            SaveResults(repmat(cvStat./sum(CV,1),1,2), 'CV', ...
                sprintf('scaled CV: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials));  % JL 02192015: sum(CV,2) was changed to sum(CV,1)
             SaveResults(repmat(current_burstStat./sum(burstStat,1),1,2), 'scaledBursts', ...
                 sprintf('scaled Bursts: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials)); % JL 02262015: uncommented this 2 lines, and the sum(burstStat,2) was changed to sum(burstStat,1)
             SaveResults(repmat(FanoFStat./sum(FanoFStat,1),1,2), 'FanoF', ...
                sprintf('scaled FanoF: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials));  % added JL 
        end

        % Save files
        if 1
            SaveResults(repmat(current_stdStat,1,2), 'STD', ...
                sprintf('STD: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials));
            SaveResults(repmat(current_aveStat,1,2), 'GAVE', ...
                sprintf('GAVE: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials));
            SaveResults(repmat(cvStat,1,2), 'CV', ...
                sprintf('CV: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials));
            SaveResults(repmat(current_burstStat,1,2), 'Bursts', ...
                 sprintf('Bursts: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials)); % JL 02262015: uncommented this 2 lines
            SaveResults(repmat(FanoFStat,1,2), 'FanoF', ...
                sprintf('FanoF: %s (%d segments)', freqbands{ifreq,1}, nGoodTrials)); % added JL 

        end
        
        
        % SaveResults(repmat(zStat,1,2), 'Zgave', ...
        %             sprintf('Zgave: %s (%d segments)', freqbands{ifreq,1}, length(sInputs)));
    end

    try
        SaveResults(low_vs_high_freq_contrastMap, 'contrast', ...
            sprintf('L2H (each of %d segments)',nGoodTrials));
        SaveResults(repmat(std(low_vs_high_freq_contrastMap,[],2),1,2), 'stdcontrast', ...
            sprintf('STD of L2H (across %d segments)',nGoodTrials));
        SaveResults(repmat(mean(low_vs_high_freq_contrastMap,2),1,2), 'avecontrast', ...
            sprintf('AVE of L2H (across %d segments)',nGoodTrials));

        %Compute ratio of low < beta to high > beta frequency components
        for ifreq = 1:size(freqbands,1) % Normalize power maps
            aveStat(:,ifreq) =  aveStat(:,ifreq) / max(aveStat(:,ifreq));
            stdStat(:,ifreq) = stdStat(:,ifreq) / max(stdStat(:,ifreq));
        end
        ave_contrastMap = (4 * sum(aveStat(:,1:3),2) - 3 *sum(aveStat(:,5:end),2) ) ./ (4 * sum(aveStat(:,1:3),2) + 3 *sum(aveStat(:,5:end),2) );
        std_contrastMap =  (4 * sum(stdStat(:,1:3),2) - 3 *sum(stdStat(:,5:end),2) ) ./ (4 * sum(stdStat(:,1:3),2) + 3 *sum(stdStat(:,5:end),2) );

        SaveResults(repmat(std_contrastMap,1,2), 'contraststd', ...
            sprintf('L2H of STD (%d segments)',nbSamplesA));
        SaveResults(repmat(ave_contrastMap,1,2), 'contrastave', ...
            sprintf('L2H of GAVE (%d segments)',nbSamplesA));
    catch
    end
    
    
    
end


%% ===== SAVE RESULTS =====
    function SaveResults(value, fileTag, Comment)
        % Fill output structure
        kernelMat.ImageGridAmp = value;
        kernelMat.Comment      = Comment;
        kernelMat.Time         = 1:size(value,2);
        % Output filename
        OutputFiles{end+1} = bst_process('GetNewFilename', OutputPath, ['results_decomp_', fileTag]);
        % Save file
        save(OutputFiles{end}, '-struct', 'kernelMat');
        % Register in database
        db_add_data(iStudy, OutputFiles{end}, kernelMat);
    end
end


