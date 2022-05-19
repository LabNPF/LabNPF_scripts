%%%%%%%%%%Deletes Bad Channels and Selects Trim Intervals%%%&%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%27/07/2018%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Usage: 

eeglab;

%Get directory name to search for files
directory_name = uigetdir;
files = dir(fullfile(directory_name, '*_hp.set'));

%Creates index of all the .set files in the directory
fileIndex = find(~[files.isdir]);

%Loads each .set file

for i = 1:length(fileIndex)

STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

fileName = files(fileIndex(i)).name;


[PATHSTR,NAME,EXT] = fileparts(fileName);

EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
EEG = eeg_checkset( EEG );

Intervalo = input ('Trim Interval-- ');
Canais = input ('electrodes to remove -- ');

if Canais > 0
EEG = pop_select( EEG, 'time', Intervalo, 'nochannel', Canais);
else EEG = pop_select( EEG, 'time', Intervalo);
end;

EEG.setname=[NAME, '_del'];
EEG = eeg_checkset( EEG );

EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', directory_name);

clear remover

end;



%Hooray!
disp('*** All files successfully processed! ***');



