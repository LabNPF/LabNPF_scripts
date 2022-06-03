%% 01 - Create event list

eeglab; %Open EEGLab

directory_name = uigetdir; %Select directory of the files
%cd(directory_name); %Change working directory
ref_files = dir(fullfile(directory_name, '*_Ref.set'));

mkdir(directory_name, 'ERPLAB'); %Create new directory for ERPLab files

ref_fileIndex = find(~[ref_files.isdir]);

for i = 1:length(ref_fileIndex) %Creates and saves the event list
    fileName = ref_files(ref_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
    EEG = eeg_checkset( EEG );

    EEG.setname=[NAME, '_elist'];

    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', ...
    [directory_name '\ERPLAB\' EEG.setname, '.txt'] );

    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], [directory_name '\ERPLAB']);
end

disp('*** All files successfully exported! ***');

%% 02 - Assign Bins

erp_directory_name = strcat(directory_name,'/ERPLAB');

elist_files = dir(fullfile(erp_directory_name, '*_elist.set'));

elist_fileIndex = find(~[elist_files.isdir]);

for i = 1:length(elist_fileIndex) %Assigns Bins
    fileName = elist_files(elist_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', erp_directory_name);
    EEG = eeg_checkset( EEG );

    EEG.setname=[NAME, '_BIN'];

    EEG  = pop_binlister( EEG , 'BDF', convertStringsToChars(erp_directory_name+"/A_BinDescriptorFile_AvCond.txt"), ...
    'ExportEL', [erp_directory_name '\' EEG.setname, '.txt'] , 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' ); 

    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], erp_directory_name);
end

disp('*** Bins successfully assigned! ***');

%% 03 - Extract Bin based epochs

bin_files = dir(fullfile(erp_directory_name, '*_BIN.set'));

bin_fileIndex = find(~[bin_files.isdir]);

for i = 1:length(bin_fileIndex) %Extracts epochs
    fileName = bin_files(bin_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', erp_directory_name);
    EEG = eeg_checkset( EEG );

    EEG.setname=[NAME, '_epoched'];

    EEG = pop_epochbin( EEG , [-200.0  800.0],  'pre');

    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], erp_directory_name);
end

disp('*** Bin based epochs successfully extracted! ***');

%% 04 - Update event list with marked epochs

epoched_files = dir(fullfile(erp_directory_name, '*_epoched.set'));

epoched_fileIndex = find(~[epoched_files.isdir]);

for i = 1:length(epoched_fileIndex) %Updates the event list with the marked epochs
    fileName = epoched_files(epoched_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', erp_directory_name);
    EEG = eeg_checkset( EEG );

    EEG.setname=[NAME, '_artef'];

    EEG = pop_syncroartifacts(EEG, 'direction', 'eeglab2erplab');
    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], erp_directory_name);
end

disp('*** Event list successfully updated! ***');

%% 05 - Create ERP set

artef_files = dir(fullfile(erp_directory_name, '*_artef.set'));

artef_fileIndex = find(~[artef_files.isdir]);

for i = 1:length(artef_fileIndex) %Creates ERP set
    fileName = artef_files(artef_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', erp_directory_name);
    EEG = eeg_checkset( EEG );

    ERPNAME=[NAME, '_ERP'];

    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname', ERPNAME, 'filename', [ERPNAME, '.erp'], 'filepath', erp_directory_name, 'Warning',...
 'on');

    EEG = eeg_checkset(EEG);
    eeglab redraw;
end

disp('*** ERP set successfully created! ***');

%% 06 - New Bins ERP set

erp_files = dir(fullfile(erp_directory_name, '*_ERP.erp'));

erp_fileIndex = find(~[erp_files.isdir]);

for i = 1:length(erp_fileIndex)
    fileName = erp_files(erp_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    ERP = pop_loaderp( 'filename', fileName, 'filepath',erp_directory_name);

    ERPNEWNAME=[NAME, '_NewBin'];

    ERP = pop_binoperator( ERP, {  'nb1 = wavgbin(1,2,3,4,5,6) label Aversive',  'nb2 = wavgbin(7,8,9) label Non-Aversive',  'nb3 = wavgbin(1,4) label AversiveB1',...
  'nb4 = wavgbin(2,5) label AversiveB2',  'nb5 = wavgbin(3,6) label AversiveB3',  'nb6 = b7 label Non-AversiveB1',  'nb7 = b8 label Non-AversiveB2', ...
  'nb8 = b9 label Non-AversiveB3', 'nb9 = b10 label Ext_Aversive', 'nb10 = wavgbin(11,12) label Ext_NonAversive'});

    ERP = pop_savemyerp(ERP, 'erpname', ERPNEWNAME, 'filename', [ERPNEWNAME, '.erp'], 'filepath', erp_directory_name, 'Warning',...
 'on');

    eeglab redraw;
end

disp('*** All files successfully processed! ***');

%% 07 - New channels ERP set

newbin_files = dir(fullfile(erp_directory_name, '*_NewBin.erp'));

newbin_fileIndex = find(~[newbin_files.isdir]);

for i = 1:length(newbin_fileIndex)
    fileName = newbin_files(newbin_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    ERP = pop_loaderp( 'filename', fileName, 'filepath',erp_directory_name);

    ERPNEWNAME=[NAME, '_AvgChan'];

    ERP = pop_erpchanoperator( ERP, {'ch130 = (ch4+ch5+ch10+ch11+ch12+ch16+ch18+ch19)/8 label AvgFZ', 'ch131 = (ch19+ch20+ch23+ch24+ch27+ch28)/6 label AvgF3',...
  'ch132 = (ch3+ch4+ch117+ch118+ch123+ch124)/6 label AvgF4', 'ch133 = (ch7+ch31+ch55+ch80+ch106+ch129)/6 label AvgCZ', 'Ch134 = (ch29+ch30+ch35+ch37+ch36+ch41+ch42)/7 label AvgC3',...
  'Ch135 = (ch87+ch93+ch103+ch104+ch105+ch110+ch111)/7 label AvgC4', 'Ch136 = (ch61+ch62+ch67+ch72+ch77+ch78)/6 label AvgPZ', 'Ch137 = (ch42+ch47+ch51+ch52+ch53+ch59+ch60)/7 label AvgP3',...
  'Ch138 = (ch85+ch86+ch91+ch92+ch93+ch97+ch98)/7 label AvgP4'}, 'ErrorMsg', 'popup', 'Warning', 'on');

    ERP = pop_savemyerp(ERP, 'erpname', ERPNEWNAME, 'filename', [ERPNEWNAME, '.erp'], 'filepath', erp_directory_name, 'Warning',...
 'on');

    eeglab redraw;
end

disp('*** All files successfully processed! ***');

%% 08 - Extract epoch number

avgchan_files = dir(fullfile(erp_directory_name, '*_AvgChan.erp'));

avgchan_fileIndex = find(~[avgchan_files.isdir]);

for i = 1:length(avgchan_fileIndex)
    fileName = avgchan_files(avgchan_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    ERP = pop_loaderp( 'filename', fileName, 'filepath',erp_directory_name);

    NTRIALS(i,1:10)=ERP.ntrials.accepted;

    eeglab redraw;
end

disp('*** All files successfully processed! ***');