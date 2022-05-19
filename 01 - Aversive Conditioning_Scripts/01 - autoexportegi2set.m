%%%%%%%%%%AutoExportEGI2Set%%%%%%%%%%%
%%%%%%%%%%Tiago O. Paiva%%%%%%%%%%%%
%%%%%%%%%%%%%%07-09-2012%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Usage: 
%%      -run autoexport.m
%%      -select directory containing the .raw files
%%      -a new sub-folder called \.set will be created containing the new .set files
%%

eeglab;

%Get directory name to search for files (event files must be in this same
%directory)
directory_name = uigetdir;
cd(directory_name);
files = dir(fullfile(directory_name, '*.raw'));

%Create new directory to save .set files
mkdir(directory_name, '.set');

%Creates index of all the .asc files in the directory
fileIndex = find(~[files.isdir]);

%Loads each .avr files and saves them as .set
for i = 1:length(fileIndex)

fileName = files(fileIndex(i)).name;
[PATH, NAME, EXT] = fileparts(fileName);

EEG = pop_readegi([directory_name, '\', NAME, '.raw'], [],[],'auto');
EEG = eeg_checkset(EEG);
eeglab redraw;

EEGOUT = pop_saveset(EEG,  [NAME, '.set'], [directory_name '\.set']);

end

%Hooray!
disp('*** All files successfully exported! ***');