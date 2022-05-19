%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           ERPLAB SCRIPTS             %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           Assign BINS to Events      %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           Tiago O. Paiva             %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           05-04-2017                 %%%%%%%%%%%%%%%%%%%%


eeglab;

%Get directory name to search for files (event files must be in this same
%directory)
directory_name = uigetdir;
cd(directory_name);
files = dir(fullfile(directory_name, '*_elist.set'));

%Create new directory to save .set files
%mkdir(directory_name, 'ERPLAB');

%Creates index of all the .asc files in the directory
fileIndex = find(~[files.isdir]);

%Loads each .avr files and saves them as .set
for i = 1:length(fileIndex)

fileName = files(fileIndex(i)).name;
[PATH, NAME, EXT] = fileparts(fileName);

EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
EEG = eeg_checkset( EEG );

EEG.setname=[NAME, '_BIN'];

%%%%%%% Function Assignement %%%%%%%%
EEG  = pop_binlister( EEG , 'BDF', 'D:\Tiago O. Paiva\07 - PhD\01 - RawData\01 - Aversive Conditioning_Scripts\A_BinDescriptorFile_AvCond.txt', ...
    'ExportEL', [directory_name '\' EEG.setname, '.txt'] , 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' ); 

EEG = eeg_checkset(EEG);
eeglab redraw;

EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], directory_name);

end

%Hooray!
disp('*** All files successfully processed! ***');
