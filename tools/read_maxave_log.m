% Read maxfilter_ave.log

fid=fopen(logFile,'r');

m=1;
next=1;
p={};
p{1} = fgetl(fid);

while p{m}
    m=m+1;
    p{m} = fgetl(fid);
end

% Find samp freq
pattern = 'FIFF_SFREQ';
x=regexp(p, pattern);
c=cellfun(@isempty, x);
iSfreq = find(c==0);
s = regexp(p{iSfreq(1)},'\s','split');
sfreq = str2double(s{6});

% Find skipped samples
pattern = 'samples skipped';
x=regexp(p, pattern);
c=cellfun(@isempty, x);
iSkipped = find(c==0);
s = regexp(p{iSkipped(1)},'\s','split');
sStart = str2double(s{4});

% Find events
pattern = ') ev ';
x=regexp(p, pattern);
c=cellfun(@isempty, x);
iEv = find(c==0);

n=1;
eventList(n,1) = sStart;
eventList(n,2) = sStart/sfreq;
eventList(n,3) = 0;
eventList(n,4) = 0;
n=n+1;
  
for i=1:length(iEv)
    s = regexp(p{iEv(i)},'\s','split');
    samps = str2double(s{7});
    
    % find the event type
    ev = str2double(s{5});
    
    eventList(n,1) = samps;
    eventList(n,2) = samps/sfreq;
    eventList(n,3) = 0;
    eventList(n,4) = Events(ev).eventNewBits;
    n=n+1;
end

% Save to a file
[p,n,e] = fileparts(rawFile);
saveFile = fullfile(p, [n '.eve']);
fid = fopen(saveFile, 'w');
fprintf(fid, '%7.0f %4.3f %5.0f %5.0f\n',eventList');
fclose(fid);
