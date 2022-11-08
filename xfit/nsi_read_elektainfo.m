function [sensors,hs,trans,proj,nproj]=nsi_read_elektainfo(datafile)
%
%   nsi_read_elektainfo
%
%       This function reads Elekta information about sensor positions and 
%       orientations, and tranforms them to head-centered coordinates. It
%       also outputs the head shape digitization points, and the
%       affine transformation matrix from device to head-centered
%       coordinates.
%
%   usage:  [sensors,hs,trans]=nsi_read_elektainfo(datafile);
%
%   input:  
%
%       datafile is data fiff file from Elekta MEG system.
%
%   output:
%
%       sensors is a structure containing sensor positions and orientations 
%           in head centered coordinate system.
%
%       hs is matrix containg head digitization points.
%
%       trans is transformation matrix from device to head-centered
%           coordinates.
%
%       proj is the SSP projection matrix.
%
%       nproj is the number of dimensions projected out. (usually zero).

% Copyright (C) 2008 - Rey Rene Ramirez
%
% Authors:  Rey Rene Ramirez, Ph.D.   e-mail: rrramirez at mcw.edu
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


[info] = fiff_read_meas_info(datafile);
[proj,nproj] = mne_make_projector_info(info);

nhsp=length(info.dig);
for k=1:nhsp
    hs(:,k)=double(info.dig(k).r);
end

trans=info.dev_head_t.trans;

nsensors=info.nchan;
other=[];
for k=1:nsensors
    coil_type=info.chs(k).coil_type;
    if coil_type==3012 || coil_type==3022
        sensors(k).coiltype=coil_type;
        chpos=info.chs(k).loc(1:3);
        chxdir=info.chs(k).loc(4:6);
        chydir=info.chs(k).loc(7:9);
        chzdir=info.chs(k).loc(10:12);
        sensors(k).pos=trans(1:3,:)*[chpos; 1];
        sensors(k).xdir=trans(1:3,1:3)*chxdir;
        sensors(k).xdir=sensors(k).xdir./norm(sensors(k).xdir);
        sensors(k).ydir=trans(1:3,1:3)*chydir;
        sensors(k).ydir=sensors(k).ydir./norm(sensors(k).ydir);
        sensors(k).zdir=trans(1:3,1:3)*chzdir;
        sensors(k).zdir=sensors(k).zdir./norm(sensors(k).zdir);
    else
        sensors(k).coiltype='other';
        other=[other k];
    end
end
sensors(other)=[];