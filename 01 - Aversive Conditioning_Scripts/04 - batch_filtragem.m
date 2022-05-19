%%%%%%%%%%Filter&ICA Batch%%%%%%%%%%%
%%%%%%%%%%%%%%24.05.2010%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Usage: 
%%      -run batch_filtragem+ICA.m
%%      -select directory containing the .set files
%%      -for each .set file a new one will be created with the filtered
%%      data and computed ICA weights
%%

eeglab;

%Get directory name to search for files
directory_name = uigetdir; %%%pede para seleccionar um diretorio
files = dir(fullfile(directory_name, '*_Loc.set'));

%Creates index of all the .set files in the directory
fileIndex = find(~[files.isdir]);

%Loads each .set files, filters (lP 30Hz followed by HP 0.3Hz) and computes
%ICA Weights

for i = 1:length(fileIndex)
fileName = files(fileIndex(i)).name;

[PATH, NAME, EXT] = fileparts(fileName);

EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
EEG = eeg_checkset( EEG );

% EEG = pop_eegfiltnew( EEG, 0, 30);
% EEG.setname=[NAME, '_lp'];
% EEG = eeg_checkset( EEG );
% 
% EEG = pop_eegfiltnew( EEG, 0.1, 0);
% EEG.setname=[NAME, '_lp_hp'];
% EEG = eeg_checkset( EEG );

EEG = pop_eegfilt( EEG, 0, 30, [], [0], 0, 0, 'fir1', 0);
EEG.setname=[NAME, '_lp'];
EEG = eeg_checkset( EEG );

EEG = pop_eegfilt( EEG, 0.1, 0, [], [0], 0, 0, 'fir1', 0);
EEG.setname=[NAME, '_lp_hp'];
EEG = eeg_checkset( EEG );

EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', directory_name);


end;

%Hooray!
disp('*** All files successfully filtered! ***');



%Hooray!
%disp('*** All files successfully gone! ***');

