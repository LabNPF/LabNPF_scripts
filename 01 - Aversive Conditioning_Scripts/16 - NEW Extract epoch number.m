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
files = dir(fullfile(directory_name, '*_AvgChan.erp'));

%Create new directory to save .set files
%mkdir(directory_name, 'ERPLAB');

%Creates index of all the .asc files in the directory
fileIndex = find(~[files.isdir]);


%Loads each .avr files and saves them as .set
for i = 1:length(fileIndex)

fileName = files(fileIndex(i)).name;
[PATH, NAME, EXT] = fileparts(fileName);

ERP = pop_loaderp( 'filename', fileName, 'filepath',directory_name);

NTRIALS(i,1:10)=ERP.ntrials.accepted;
%NTRIALS_Rej(i,1:16)=ERP.ntrials.rejected;

eeglab redraw;


%EEGOUT = pop_saveset(EEG,  [EEG.setname, '.set'], directory_name);

end

%Hooray!
disp('*** All files successfully processed! ***');
