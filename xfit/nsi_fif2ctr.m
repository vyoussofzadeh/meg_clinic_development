function [ctr,r]=nsi_fif2ctr(datafile)
%
%   This function finds the center of sphere from fif file input.
%
%   usage: [ctr,r]=nsi_fif2ctr(datafile);
%
%   input:  
%       datafile = the name of the fif file (must cd there, if not full
%                       path).
%   outputs:  
%       ctr  the center of the sphere in meters.
%       r radius of the sphere.               

[sensors,hs,trans]=nsi_read_elektainfo(datafile);
[ctr,r]=nsi_s_fit(hs);