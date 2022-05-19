%%%%%%%%%%Deletes Bad Channels and Selects Trim Intervals%%%&%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%27/07/2018%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Usage: 

eeglab;

%Get directory name to search for files
directory_name = uigetdir;
files = dir(fullfile(directory_name, '*.set'));

%Creates index of all the .set files in the directory
fileIndex = find(~[files.isdir]);

%Loads each .set file

for i = 1:length(fileIndex)

STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

fileName = files(fileIndex(i)).name;


[PATHSTR,NAME,EXT] = fileparts(fileName);

EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
EEG = eeg_checkset( EEG );


if EEG.nbchan>129
EEG = pop_select( EEG, 'nochannel', [130]);
end;

%EEG.setname=[NAME, '_del'];
EEG = eeg_checkset( EEG );

EEG = pop_saveset( EEG,  'filename', fileName , 'filepath', directory_name);

end;



%Hooray!
disp('*** All files successfully processed! ***');



