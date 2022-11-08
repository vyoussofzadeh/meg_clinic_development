function [sSubject, iSubject] = mc_bst_create_subject(subjectName)
% mc_bst_create_subject: uses brainstorm scripts to create a new subject
% USAGE:    mc_bst_create_protocol()
%
% INPUT:    subjectName = name of subject (last_first)
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 2010    Creation (adapted from brainstorm3 scripts)
% -------------------------------------------------------------------------


% Set default anatomy
sColin = bst_get('AnatomyDefaults', 'Colin27');
db_set_template(0, sColin, 0);

%% ===== CREATE SUBJECT =====
UseDefaultAnat = 0;
UseDefaultChannel = 0;
[sSubject, iSubject] = db_add_subject(subjectName, [], UseDefaultAnat, UseDefaultChannel);
% If an error occured in subject creation (subject already exists, impossible to create folders...)
if isempty(sSubject)
    error('Could not create subject.');
end  