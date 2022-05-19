


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


EEG = pop_chanedit(EEG, 'load',{'D:\\Tiago O. Paiva\\07 - PhD\\01 - RawData\\01 - Aversive Conditioning_Scripts\\GSN-HydroCel-129.sfp' 'filetype' 'autodetect'});
EEG.setname=[NAME, '_Loc'];
EEG = eeg_checkset( EEG );

EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', directory_name);
end;



%Hooray!
disp('*** All files successfully processed! ***');

