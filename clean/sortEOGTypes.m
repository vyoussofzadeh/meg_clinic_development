function newEvents = sortEOGTypes(events, filteog, firstSamp, corrVal)
% sortEOGTypes

% Init ref blink count
j=1;
% Create first ref blink type
t=events(1);
refBlink(1,:) = filteog(t-400:t+400);
type(1) = 801;
% Loop through all events
for i=2:length(events)
    t = events(i);
    if t+400 > length(filteog)
        break;
    end
    newBlink = filteog(t-400:t+400);
    % Loop through all types
    for j=1:size(refBlink,1)
        c = corrcoef(newBlink, refBlink(j,:));
        if c(1,2) > corrVal
            type(i) = 800+j;
            break;
        else
            type(i) = -1;
        end
    end
    % If no match create a new type
    if type(i) == -1
        refBlink(j+1,:) = newBlink;
        type(i) = 800+j+1;
    end
end

% format events for mne 
newEvents(:,1) = events(1:length(type)) + firstSamp;
newEvents(:,2) = newEvents(:,1)/2000;
newEvents(:,3) = 0;
newEvents(:,4) = type;
