
% Get the first data file structure for updating
newData = fiff_read_evoked_all(char(inputList(1)));

for jj = 1:length(inputEvents)
    for kk = 1:length(inputList)
        data = fiff_read_evoked_all(char(inputList(kk)));
        nave(kk) = data.evoked(jj).nave;
        epochs(kk,:,:) = data.evoked(jj).epochs;
    end
    newData.evoked(jj).nave = sum(nave);
    newData.evoked(jj).epochs = mean(epochs,1);
end

fiff_write_evoked(char(savePath),newData);