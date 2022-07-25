%% 00 - Global variables

bin_def = "/A_BinDescriptorFile_AvCond.txt"; %Name of the bin descriptor file. Default: "/A_BinDescriptorFile_AvCond.txt"
epoch_startend = [-200.0  800.0]; %Start and end of the epochs. Default:[-200.0 800.0]
%Sections 06 and 07 have bin and channel operators, respectively, that are study dependent so there's no default.
fid = fopen('log.txt','a+'); %Creates or opens the log file
fclose(fid);

directory_name = uigetdir; %Select directory of the files
cd(directory_name); %Change working directory
EEG_directory_name = strcat(directory_name,'/EEG_Set');
ref_files = dir(fullfile(EEG_directory_name, '*_Ref.set'));

mkdir(directory_name, '/ERP_Set'); %Create new directory for ERPLab files
ERP_directory_name = strcat(directory_name,'/ERP_Set');

%% 01 - Create event list

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab; %Open EEGLab

ref_fileIndex = find(~[ref_files.isdir]);

for i = 1:length(ref_fileIndex) %Creates and saves the event list
    fileName = ref_files(ref_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
    EEG = eeg_checkset( EEG );
    
    old_EEG = EEG;

    EEG.setname=[NAME, '_elist'];

    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', ...
    [directory_name '\ERP_Set\' EEG.setname, '.txt'] );

    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], [directory_name '\ERP_Set']);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Created event list; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** All files successfully exported! ***');

%% 02 - Assign Bins

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

elist_files = dir(fullfile(ERP_directory_name, '*_elist.set'));

elist_fileIndex = find(~[elist_files.isdir]);

for i = 1:length(elist_fileIndex) %Assigns Bins
    fileName = elist_files(elist_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', ERP_directory_name);
    EEG = eeg_checkset( EEG );
    
    old_EEG = EEG;

    EEG.setname=[NAME, '_BIN'];

    EEG  = pop_binlister( EEG , 'BDF', convertStringsToChars(directory_name+bin_def), ...
    'ExportEL', [ERP_directory_name '\' EEG.setname, '.txt'] , 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' ); 

    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], ERP_directory_name);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Assigned bins; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** Bins successfully assigned! ***');

%% 03 - Extract Bin based epochs

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

bin_files = dir(fullfile(ERP_directory_name, '*_BIN.set'));

bin_fileIndex = find(~[bin_files.isdir]);

for i = 1:length(bin_fileIndex) %Extracts epochs
    fileName = bin_files(bin_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', ERP_directory_name);
    EEG = eeg_checkset( EEG );
    
    old_EEG = EEG;

    EEG.setname=[NAME, '_epoched'];

    EEG = pop_epochbin( EEG , epoch_startend,  'pre');

    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], ERP_directory_name);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Extracted bin based epochs; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** Bin based epochs successfully extracted! ***');

%% 04 - Update event list with marked epochs

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

epoched_files = dir(fullfile(ERP_directory_name, '*_epoched.set'));

epoched_fileIndex = find(~[epoched_files.isdir]);

for i = 1:length(epoched_fileIndex) %Updates the event list with the marked epochs
    fileName = epoched_files(epoched_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', ERP_directory_name);
    EEG = eeg_checkset( EEG );
    
    old_EEG = EEG;

    EEG.setname=[NAME, '_artef'];

    EEG = pop_syncroartifacts(EEG, 'direction', 'eeglab2erplab');
    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], ERP_directory_name);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Updated event list with marked epochs; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** Event list successfully updated! ***');

%% 05 - Create ERP set

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

artef_files = dir(fullfile(ERP_directory_name, '*_artef.set'));

artef_fileIndex = find(~[artef_files.isdir]);

for i = 1:length(artef_fileIndex) %Creates ERP set
    fileName = artef_files(artef_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', ERP_directory_name);
    EEG = eeg_checkset( EEG );

    ERPNAME=[NAME, '_ERP'];

    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname', ERPNAME, 'filename', [ERPNAME, '.erp'], 'filepath', ERP_directory_name, 'Warning',...
 'on');

    EEG = eeg_checkset(EEG);
    eeglab redraw;
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Created ERP set; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** ERP set successfully created! ***');

%% 06 - New Bins ERP set

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

erp_files = dir(fullfile(ERP_directory_name, '*_ERP.erp'));

erp_fileIndex = find(~[erp_files.isdir]);

for i = 1:length(erp_fileIndex)
    fileName = erp_files(erp_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    ERP = pop_loaderp( 'filename', fileName, 'filepath',ERP_directory_name);
    
    old_ERP = ERP;

    ERPNEWNAME=[NAME, '_NewBin'];

    ERP = pop_binoperator( ERP, {  'nb1 = wavgbin(1,2,3,4,5,6) label Aversive',  'nb2 = wavgbin(7,8,9) label Non-Aversive',  'nb3 = wavgbin(1,4) label AversiveB1',...
  'nb4 = wavgbin(2,5) label AversiveB2',  'nb5 = wavgbin(3,6) label AversiveB3',  'nb6 = b7 label Non-AversiveB1',  'nb7 = b8 label Non-AversiveB2', ...
  'nb8 = b9 label Non-AversiveB3', 'nb9 = b10 label Ext_Aversive', 'nb10 = wavgbin(11,12) label Ext_NonAversive'});

    ERP = pop_savemyerp(ERP, 'erpname', ERPNEWNAME, 'filename', [ERPNEWNAME, '.erp'], 'filepath', ERP_directory_name, 'Warning',...
 'on');

    eeglab redraw;
    
    if isequaln(old_ERP,ERP)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; New bins; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** All files successfully processed! ***');

%% 07 - New channels ERP set

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

newbin_files = dir(fullfile(ERP_directory_name, '*_NewBin.erp'));

newbin_fileIndex = find(~[newbin_files.isdir]);

for i = 1:length(newbin_fileIndex)
    fileName = newbin_files(newbin_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    ERP = pop_loaderp( 'filename', fileName, 'filepath',ERP_directory_name);
    
    old_ERP = ERP;

    ERPNEWNAME=[NAME, '_AvgChan'];

    ERP = pop_erpchanoperator( ERP, {'ch130 = (ch4+ch5+ch10+ch11+ch12+ch16+ch18+ch19)/8 label AvgFZ', 'ch131 = (ch19+ch20+ch23+ch24+ch27+ch28)/6 label AvgF3',...
  'ch132 = (ch3+ch4+ch117+ch118+ch123+ch124)/6 label AvgF4', 'ch133 = (ch7+ch31+ch55+ch80+ch106+ch129)/6 label AvgCZ', 'Ch134 = (ch29+ch30+ch35+ch37+ch36+ch41+ch42)/7 label AvgC3',...
  'Ch135 = (ch87+ch93+ch103+ch104+ch105+ch110+ch111)/7 label AvgC4', 'Ch136 = (ch61+ch62+ch67+ch72+ch77+ch78)/6 label AvgPZ', 'Ch137 = (ch42+ch47+ch51+ch52+ch53+ch59+ch60)/7 label AvgP3',...
  'Ch138 = (ch85+ch86+ch91+ch92+ch93+ch97+ch98)/7 label AvgP4'}, 'ErrorMsg', 'popup', 'Warning', 'on');

    ERP = pop_savemyerp(ERP, 'erpname', ERPNEWNAME, 'filename', [ERPNEWNAME, '.erp'], 'filepath', ERP_directory_name, 'Warning',...
 'on');

    eeglab redraw;
    
    if isequaln(old_ERP,ERP)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; New channels; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** All files successfully processed! ***');

%% 08 - Extract epoch number

if exist('bin_def','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

avgchan_files = dir(fullfile(ERP_directory_name, '*_AvgChan.erp'));

avgchan_fileIndex = find(~[avgchan_files.isdir]);

size_ERPbin = size(ERP.bindata);

NTRIALS = zeros(length(avgchan_fileIndex),size_ERPbin(3));

for i = 1:length(avgchan_fileIndex)
    fileName = avgchan_files(avgchan_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    ERP = pop_loaderp( 'filename', fileName, 'filepath',ERP_directory_name);

    NTRIALS(i,:)=ERP.ntrials.accepted;

    eeglab redraw;
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Extracted epoch number; %s\n',i,datestr(now,'HH:MM:SS.FFF'));
    fclose(fid);
    
end

disp('*** All files successfully processed! ***');