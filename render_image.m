function render_image(varargin)
% render_image: callback function from MEG-Clinic, Render Selected Image File (rt click menu)
%
% USAGE:    set(renderMenuItem, 'ActionPerformedCallback', {@render_image, mc})
%           render_image(mc)
%
% INPUT:    mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 15-DEC-2009    Creation
% EB 26-MAY-2010    Updates for callback
% -------------------------------------------------------------------------

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

% Get the currently selected file
imageFile = char(mc.getInfo(GUI.Config.I_SELECTEDFILE));

[dir name ext versn] = fileparts(char(imageFile));
ext = strrep(ext, '.', '');
if ~isempty(imformats(ext))
    I = imread(char(imageFile));
    figure
    imshow(I)
else
    % The format is not compatable
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR, 'Selected file must be an image file.');
end
