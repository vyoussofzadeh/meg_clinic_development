function [ctr,r]=nsi_s_fit(hs)
%
%   nsi_s_fit
%
%   This program makes a single spherical fit of the head.
%
%   usage:  [ctr,r]=nsi_s_fit(hs);
%
%   input:
%       hs is the matrix of digitized head-shape points.
%
%   outputs:
%
%       ctr is the center of the sphere.
%
%       r is the radius.
% 
%   Also see nsi_fsf.m
%

% Copyright (C) 2001- Rey Rene Ramirez
%
% Authors:  Rey Rene Ramirez, Ph.D.   e-mail: rrramirez at mcw.edu
%           Eugene Kronberg,    NYU Medical Center
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


xmin=min(hs(1,:));
xmax=max(hs(1,:));
xradius=(xmax-xmin)/2;

ymin=min(hs(2,:));
ymax=max(hs(2,:));
yradius=(ymax-ymin)/2;

radius=mean([xradius yradius]);

zmax=max(hs(3,:));

ctr=[mean([xmin xmax]); ...
     mean([ymin ymax]); ...
     zmax-radius];

xyzr=fminsearch('nsi_fsf',[ctr;radius],[],hs);
ctr=xyzr(1:3);
r=xyzr(4);
