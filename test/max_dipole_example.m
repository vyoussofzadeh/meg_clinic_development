i=[DipolesInfo.Dipole.Index];
whos i
g=[DipolesInfo.Dipole.Goodness];
whos g i
uni=unique(i)
i1=find(i==0);
whos i1
i1=find(i==1);
whos i1
z=zeros(1,1739);
z(i1)=g(i1);
[dum,iii]=max(z);
iii
DipolesInfo.Dipole(iii)