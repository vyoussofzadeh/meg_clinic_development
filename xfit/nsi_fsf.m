function cost=nsi_fsf(xyzr,hs)
%
%   nsi_fsf
%
%   usage:  cost=nsi_fsf(xyzr,hs);
% 
%   This function computes the cost minimized by nsi_s_fit.m    
%
%   inputs:
%
%       xyzr = [ctr;r]
%       ctr is center of sphere and r is the initial guess for radius.
%
%       hs is a matrix containing the headshape points (the coordinates of 
%       the digitized scalp surface.
%
%   output:
%
%       cost is the cost being minimized with nsi_s_fit.m
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

ctr=xyzr(1:3);
r=xyzr(4);

nhs=size(hs,2);
hs=hs-repmat(ctr,1,nhs);
cost=sum((sqrt(sum(hs.^2))-r*ones(1,nhs)).^2);
