function fiffReadEventFile(eventFile, listModel, includeAll)

eveNumModel = listModel;
eveNumModel.removeAllElements();

% Add an option for selecting all types
if includeAll
    element=java.lang.String.valueOf('All');
    eveNumModel.addElement(element);
end

% Find event types
name = char(eventFile);

if strfind(name,'.fif')
    events = mne_read_events(name);
else
    events = load(name);
end

numbers = int32(events(:,size(events,2)));
eveTypes = unique(numbers);


% Add the event types to the model
for n=1:length(eveTypes)
    if eveTypes(n) > 0
        element=java.lang.String.valueOf(eveTypes(n));
        eveNumModel.addElement(element);
    end
end

if includeAll
    eveNumModel.setSelectedItem(java.lang.String.valueOf(eveNumModel.getElementAt(0)));
end
        