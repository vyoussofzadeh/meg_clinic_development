function replace_text_line(file, lineNo, format, string)

fid = fopen(file,'r');
line = {};
i=1;
while ~feof(fid)
    line{i} = fgetl(fid);
    i=i+1;
end
fclose(fid);
% Replace the line with the updated string
line{lineNo} = sprintf(format,string);
fid = fopen(file,'w');
for j=1:length(line)
    fprintf(fid,'%s\n',line{j});
end
fclose(fid)
    