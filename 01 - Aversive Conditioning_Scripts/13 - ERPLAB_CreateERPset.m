%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           ERPLAB SCRIPTS             %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           Extract BIN based epochs   %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           Tiago O. Paiva             %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           05-04-2017                 %%%%%%%%%%%%%%%%%%%%


eeglab;

%Get directory name to search for files (event files must be in this same
%directory)
directory_name = uigetdir;
cd(directory_name);
files = dir(fullfile(directory_name, '*_artef.set'));

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

ERPNAME=[NAME, '_ERP'];

%%%%%%% Function Assignement %%%%%%%%
ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', ERPNAME, 'filename', [ERPNAME, '.erp'], 'filepath', directory_name, 'Warning',...
 'on');

EEG = eeg_checkset(EEG);
eeglab redraw;




%EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], directory_name);

end

%Hooray!
disp('*** All files successfully processed! ***');
