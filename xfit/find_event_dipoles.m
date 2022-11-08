function nEventDips = find_event_dipoles(file)

fid = fopen(file);

% find text lines
buffer = textscan(fid,'%s%*[^\n]');
x=char(buffer{1});
xchars = [x(:,1)' '#'];
y=findstr(xchars,'#');

% find the difference between the text lines
z = diff(y) - 1;

% diff is the number of dipoles between the text areas
ind1 = find(z > 0);

% ndips is a vector of each fit's lengths
ndips = z(ind1);
j=1;

if length(ndips)<4
    nEventDips = ndips(1);
else
    for i=1:4:length(ndips)-3
        nEventDips(j) = sum(ndips(i:i+3));
        j=j+1;
    end
end

fclose(fid);
