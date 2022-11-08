function batch_MRIandResults(ResultFiles, StoreImgDir, isRecMaps) 
% batch_MRIandResults: batch script for MEG-Clinic image batch 
%
% USAGE:    batch_MRIandResults(ResultFiles, StoreImgDir, isRecMaps)
%           
% INPUT:    ResultFiles = list of brainstorm Result files
%           StoreImgDir = directory to store images once created
%           isRecMaps = [0,1] is the Result file to image a recurrence map
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 12-JULY-2010 Creation
% -------------------------------------------------------------------------

% Create Figures
global GlobalData
for i=1:length(ResultFiles)
   
   if ~isstruct(ResultFiles)
       [sStudy, iStudy, iResult] = bst_get('ResultsFile', ResultFiles(i));
       curResult = sStudy.Result(iResult);
   else
       curResult = ResultFiles(i);
   end
   
   % Get the matching MRI file
   subjectName = fileparts(fileparts(curResult.FileName));
   sSubject = bst_get('Subject',subjectName);
   MriFile = sSubject.Anatomy.FileName;
   
    % -----Create image name
   if isRecMaps
       name = char(curResult.DataFile);
       ind = strfind(name, 'Event_');
       ind2 = strfind(name, '_trial');
       temp = name(ind:ind2-1);
       resName = [curResult.Comment '_' temp];
   else
       resName = curResult.Comment;
   end
 
   % Replace the colon with an underscore
   if strfind(resName, ':')
       newName = strrep(resName, ': ', '_');
   else
       newName = resName;
   end
   
   % Replace the backslash with an underscore
   if strfind(newName, '/')
       temp = strrep(newName, '/', '_');
   else
       temp = newName;
   end
   
   imgFile = fullfile(StoreImgDir, [sStudy.Name '_' temp '.jpg']);

   % -----Create figure
   MriFig = view_mri(MriFile, curResult.FileName);

   % -----Set Colormap (absolute by default)
   % check if file is a freq contrast (low-high), use relative colormap
   freqContrast = strfind(lower(curResult.Comment), 'low-high');
   if isRecMaps || ~isempty(freqContrast)
       sColormap = bst_colormaps('GetColormap', 'Source');
       sColormap.isAbsoluteValues = 0;
       bst_colormaps('SetColormap', 'Source', sColormap)
       bst_colormaps('SetMaxMode', 'Source', 'global');
       bst_colormaps('FireColormapChanged')
   else
       bst_colormaps('SetColormapAbsolute','Source', 1);
       bst_colormaps('SetMaxMode', 'Source', 'global');
   end

   % -----Set results file, threshold, and transparency
   appInfo = getappdata(MriFig, 'Surface');
   appInfo(1).DataSource.Type = 'Results';
   appInfo(1).DataSource.FileName = curResult.FileName;  
   appInfo(1).DataThreshold = 0.000;
   appInfo(1).DataAlpha = 0.4;   
   setappdata(MriFig, 'Surface', appInfo);
   
   GlobalData.MIP.isMipFunctional = 1;
   Handles = bst_figures('GetFigureHandles', MriFig);

   % Hide sliders
   hSliders = [Handles.sliderAxial, Handles.sliderSagittal, Handles.sliderCoronal];
   set(hSliders, 'Visible', 'off');
   Handles.jCheckViewSliders.setSelected(0);
   
   % Set Radiological
   set([Handles.axs,Handles.axc,Handles.axa],'XDir', 'reverse');
   Handles.jRadioRadiological.setSelected(1);

   figure_mri('UpdateMriDisplay', MriFig);
   % -----Save figure  
   out_figure_image(MriFig, imgFile);
   close(MriFig)
end