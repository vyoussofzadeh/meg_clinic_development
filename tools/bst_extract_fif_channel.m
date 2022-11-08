function Data = bst_extract_fif_channel(rawFile,ChannelName)
%  bst_extract_fif_channel: reads out data time series from selected
%  channels from a raw fiff file
% 
% Usage:
% 
%     Data = bst_extract_fif_channel(rawFile,ChannelName);
%     
% Description:
% 
%     rawFile: file name of the raw fif file to be read
%     ChannelName: a cell array of N channel name(s) to be read from file
%     
%     Data: an array with N rows, each row in the order of the channels specified in ChannelName
%     
     

%% -- Define fiff read parameters 
allow_maxshield = 1;


%% -- Extract selected channel time series from raw fiff file 
rawStruct = fiff_setup_read_raw(rawFile, allow_maxshield); 
time_in =  double(rawStruct.first_samp) / double(rawStruct.info.sfreq); % recording begins
time_out = double(rawStruct.last_samp) / double(rawStruct.info.sfreq); % recording ends
[sel] = fiff_pick_channels(rawStruct.info.ch_names,ChannelName,[]);
[Data,times] = fiff_read_raw_segment_times(rawStruct,time_in,time_out,sel);

%% -- Compute time derivatives of extracted time series 
dDatadt = diff(Data(1,:));
%xf = bandpassFilter(Data(2,:),rawStruct.info.sfreq,30,40);

%% -- Define events at extrema of the time derivative series
%[mdDatadt, indMax] = max(abs(dDatadt));
[XMAX,IMAX,XMIN,IMIN] = extrema(abs(dDatadt));
[N,X]=hist(XMAX, 2);
iEvent = find(abs(dDatadt)>X(end)); % Detect maxima - may need some extra cleaning
iEvent(diff(iEvent)<10)=[];
iEvent(iEvent<=rawStruct.first_samp) = [];

%iEvent = find(Data(2,:)>.995*XMAX(1)); % Detect maxima - may need some extra cleaning

%% - Create an event file corresponding to maxima
%eventArray = zeros(2*length(iEvent),4);
eventArray(1,:) = [double(rawStruct.first_samp), double(rawStruct.first_samp) / double(rawStruct.info.sfreq), 0, 0]; % Start of recording
idEvent = ceil(diff(iEvent)/2); % half-cycle latencies 
for k = 1:length(iEvent)
    eventArray(end+1,:) = double([iEvent(k), double(iEvent(k)) / double(rawStruct.info.sfreq), 0 , 1]);
    if k<length(iEvent)
        eventArray(end+1,:) = double([iEvent(k)+idEvent(k), double((iEvent(k)+idEvent(k))) / double(rawStruct.info.sfreq), 0 , 2]);
    end
end



figure, plot(Data'), hold on, plot(eventArray(eventArray(:,4)==1),Data(1,eventArray(eventArray(:,4)==1)),'ro'), 
plot(eventArray(eventArray(:,4)==2),Data(1,eventArray(eventArray(:,4)==2)),'b+'), 

eventArray(:,1) = eventArray(:,1)+double(rawStruct.first_samp);
eventArray(:,2) = eventArray(:,2)+double(time_in);

eventFile = strrep(rawFile,'.fif','_auto.eve');
feve = fopen(eventFile,'wt');
fprintf(feve,'%d %6.3f %d %d\n',eventArray');
fclose(feve);

