function nums = get_FIFF_events()


name = char(GUI.CallbackInterface.FIFFeventsFile)
events = mne_read_events(name);

numbers = int32(events(:,size(events,2)));
eveTypes = unique(numbers);
nums = cellstr(num2str(eveTypes(find(eveTypes))))

GUI.CallbackInterface.setEventsFIFF(nums);
GUI.CallbackInterface.waitFlag = java.lang.Boolean.valueOf(0);