%%%%%%%%%%Read Channel Locations and Expoch Extraction Batch%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%25.05.2010%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Usage: 
%%      -run batch_chanlocs_epochs.m
%%      -select the channels locations file
%%      - Rare and Frequent events will be extracted and saved as 2
%%      separate files


eeglab;

%Get directory name to search for files
directory_name = uigetdir;
files = dir(fullfile(directory_name, '*_interp.set')); %MUDA A TERMINAÇAO AQUI

%Creates index of all the .set files in the directory
fileIndex = find(~[files.isdir]);

%Loads each .set file

for i = 1:length(fileIndex)

STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

fileName = files(fileIndex(i)).name;


[PATHSTR,NAME,EXT] = fileparts(fileName);

EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
EEG = eeg_checkset( EEG );

EEG = pop_reref(EEG, [] ,'keepref','on');
EEG.setname=[NAME, '_Ref'];
EEG = eeg_checkset( EEG );

EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', directory_name);
end;



%Hooray!
disp('*** All files successfully processed! ***');



