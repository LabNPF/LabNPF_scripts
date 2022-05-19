%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           ERPLAB SCRIPTS             %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           Create Event Lists         %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           Tiago O. Paiva             %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%           04-04-2017                 %%%%%%%%%%%%%%%%%%%%


eeglab;

%Get directory name to search for files (event files must be in this same
%directory)
directory_name = uigetdir;
cd(directory_name);
files = dir(fullfile(directory_name, '*_Ref.set'));

%Create new directory to save .set files
mkdir(directory_name, 'ERPLAB');

%Creates index of all the .asc files in the directory
fileIndex = find(~[files.isdir]);

%Loads each .avr files and saves them as .set
for i = 1:length(fileIndex)

fileName = files(fileIndex(i)).name;
[PATH, NAME, EXT] = fileparts(fileName);

EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
EEG = eeg_checkset( EEG );

EEG.setname=[NAME, '_elist'];

EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', ...
 [directory_name '\ERPLAB\' EEG.setname, '.txt'] ); % Creates an event list and saves that eventlist

EEG = eeg_checkset(EEG);
eeglab redraw;

EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], [directory_name '\ERPLAB']);

end

%Hooray!
disp('*** All files successfully exported! ***');
