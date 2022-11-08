function batch_ContactSheetandResults(ResultFiles, StoreImgDir, type)
% batch_ContactSheetandResults: batch script for MEG-Clinic image batch 
%
% USAGE:    batch_ContactSheetandResults(ResultFiles, StoreImgDir, type)
%           
% INPUT:    ResultFiles = list of brainstorm Result files
%           StoreImgDir = directory to store images once created
%           type = 'average' or 'zscore'
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 12-JULY-2010 Creation
% -------------------------------------------------------------------------
    nFiles = length(ResultFiles);
    for i=1:nFiles

        %% Get the study and result file
        ResultToDisplay = ResultFiles{i};
        [sStudy, iStudy, iResult] = bst_get('ResultsFile', ResultFiles{i});
        curResult = sStudy.Result(iResult);
        sSubject = bst_get('Subject', sStudy.BrainStormSubject);

        %% Define inputs
        nbSamples = 12;                  % Number of images to extract
        TimeRange = [-50, 0];      % In seconds - Leave empty to use all the recordings 

        %% Display sources
        imageViews = {'right';'left';'bottom'};
        resectViews = {'left';'right'};
        % First do the right and left lateral and mesial views
        for j=1:2
            % Get default cortex file
            CortexFile = sSubject.Surface(sSubject.iCortex).FileName;
            % Call surface viewer - lateral view
            [hFig, iDS, iFig] = view_surface_data(CortexFile, ResultToDisplay, [], 'NewFigure');            
            % Set camera orientation (possible values: left, right, back, front, bottom, top)
            figure_3d('SetStandardView', hFig, imageViews(j));
            % Customize figure
            if strcmp(type,'average')
                bst_colormaps('SetColormapName','Source','cmap_hot2')
                bst_colormaps('SetColormapAbsolute','Source', 1);
                bst_colormaps('SetMaxMode', 'Source', 'global');
                bst_colormaps('FireColormapChanged')
                appInfo = getappdata(hFig, 'Surface');
                appInfo.DataLimitValue = [0 appInfo.DataMinMax(2)/3];
                setappdata(hFig, 'Surface', appInfo);
            elseif strcmp(type,'zscore')
                bst_colormaps('SetColormapName','Source','jet')
                sColormap = bst_colormaps('GetColormap', 'Source');
                sColormap.isAbsoluteValues = 0;
                bst_colormaps('SetColormap', 'Source', sColormap)
                bst_colormaps('SetMaxMode', 'Source', 'global');
                bst_colormaps('FireColormapChanged')
                bst_colormaps('SetMaxMode', 'Source', 'global');
                bst_colormaps('FireColormapChanged')
                appInfo = getappdata(hFig, 'Surface');
                appInfo.DataLimitValue = [0 appInfo.DataMinMax(2)/3];
                setappdata(hFig, 'Surface', appInfo);
            end
            
            % Hide the source colorbar
            bst_colormaps('SetDisplayColorbar', 'Source', 0);
            % Redimension figure (the contact sheet image size depends on this figure's size)
            % Position = [x,y,width,height]
            set(hFig, 'Position', [200,200,320,200]);    

            % Create contact sheet figure
            OutputImageFile = [sStudy.Name '_' curResult.Comment '_' imageViews{j} 'Lateral.jpg'];
            OutputImageFile = strrep(OutputImageFile, '#', '');
            OutputImageFile = strrep(OutputImageFile, ':', '');
            OutputImageFile = strrep(OutputImageFile, '|', '');
            OutputImageFile = fullfile(StoreImgDir,OutputImageFile);
            view_contactsheet( hFig, 'time', 'fig', OutputImageFile, nbSamples, TimeRange );
            close(hFig);
            
            % Call surface viewer - mesial view
            [hFig, iDS, iFig] = view_surface_data(CortexFile, ResultToDisplay, [], 'NewFigure');            
            % Set camera orientation
            figure_3d('SetStandardView', hFig, imageViews(j));
            % Get surface properties
            TessInfo = getappdata(hFig, 'Surface');
            iSurf    = getappdata(hFig, 'iSurface');
            % Update surface Resect field
            TessInfo(iSurf).Resect = char(resectViews(j));
            setappdata(hFig, 'Surface', TessInfo);
            figure_3d('UpdateSurfaceAlpha', hFig, iSurf);
            % Customize figure
            if strcmp(type,'average')
                bst_colormaps('SetColormapName','Source','cmap_hot2')
                bst_colormaps('SetColormapAbsolute','Source', 1);
                bst_colormaps('SetMaxMode', 'Source', 'global');
                bst_colormaps('FireColormapChanged')
                appInfo = getappdata(hFig, 'Surface');
                appInfo.DataLimitValue = [0 appInfo.DataMinMax(2)/3];
                setappdata(hFig, 'Surface', appInfo);
            elseif strcmp(type,'zscore')
                bst_colormaps('SetColormapName','Source','jet')
                sColormap = bst_colormaps('GetColormap', 'Source');
                sColormap.isAbsoluteValues = 0;
                bst_colormaps('SetColormap', 'Source', sColormap)
                bst_colormaps('SetMaxMode', 'Source', 'global');
                bst_colormaps('FireColormapChanged')
                appInfo = getappdata(hFig, 'Surface');
                appInfo.DataLimitValue = [0 appInfo.DataMinMax(2)/3];
                setappdata(hFig, 'Surface', appInfo);
            end
            
            % Hide the source colorbar
            bst_colormaps('SetDisplayColorbar', 'Source', 0);
            % Redimension figure (the contact sheet image size depends on this figure's size)
            % Position = [x,y,width,height]
            set(hFig, 'Position', [200,200,320,200]);    

            % Create contact sheet figure
            OutputImageFile = [sStudy.Name '_' curResult.Comment '_' resectViews{j} 'Mesial.jpg'];
            OutputImageFile = strrep(OutputImageFile, '#', '');
            OutputImageFile = strrep(OutputImageFile, ':', '');
            OutputImageFile = strrep(OutputImageFile, '|', '');
            OutputImageFile = fullfile(StoreImgDir,OutputImageFile);
            view_contactsheet( hFig, 'time', 'fig', OutputImageFile, nbSamples, TimeRange );
            close(hFig);
        end
        % Ventral View
        j=3;
        % Call surface viewer - mesial view
        [hFig, iDS, iFig] = view_surface_data(CortexFile, ResultToDisplay, [], 'NewFigure');            
        % Set camera orientation
        figure_3d('SetStandardView', hFig, imageViews(j));

        % Customize figure
        if strcmp(type,'average')
            bst_colormaps('SetColormapName','Source','cmap_hot2')
            bst_colormaps('SetColormapAbsolute','Source', 1);
            bst_colormaps('SetMaxMode', 'Source', 'global');
            bst_colormaps('FireColormapChanged')
            appInfo = getappdata(hFig, 'Surface');
            appInfo.DataLimitValue = [0 appInfo.DataMinMax(2)/3];
            setappdata(hFig, 'Surface', appInfo);
        elseif strcmp(type,'zscore')
            bst_colormaps('SetColormapName','Source','jet')
            sColormap = bst_colormaps('GetColormap', 'Source');
            sColormap.isAbsoluteValues = 0;
            bst_colormaps('SetColormap', 'Source', sColormap)
            bst_colormaps('SetMaxMode', 'Source', 'global');
            bst_colormaps('FireColormapChanged')
            appInfo = getappdata(hFig, 'Surface');
            appInfo.DataLimitValue = [0 appInfo.DataMinMax(2)/3];
            setappdata(hFig, 'Surface', appInfo);
        end
        
        % Hide the source colorbar
        bst_colormaps('SetDisplayColorbar', 'Source', 0);
        % Redimension figure (the contact sheet image size depends on this figure's size)
        % Position = [x,y,width,height]
        set(hFig, 'Position', [200,200,320,200]);    

        % Create contact sheet figure
        OutputImageFile = [sStudy.Name '_' curResult.Comment '_' imageViews{j} '.jpg'];
        OutputImageFile = strrep(OutputImageFile, '#', '');
        OutputImageFile = strrep(OutputImageFile, ':', '');
        OutputImageFile = strrep(OutputImageFile, '|', '');
        OutputImageFile = fullfile(StoreImgDir, OutputImageFile);
        view_contactsheet( hFig, 'time', 'fig', OutputImageFile, nbSamples, TimeRange );
        close(hFig);
    end
end