%% 01 - Autoexport egi to .set

eeglab; %Open EEGLab

raw_directory_name = uigetdir; %Select directory of the files
cd(raw_directory_name); %Change working directory
raw_files = dir(fullfile(raw_directory_name, '*.raw')); 

mkdir(raw_directory_name, '.set'); %Create new directory to save .set files

raw_fileIndex = find(~[raw_files.isdir]); %Creates index of files in directory

for i = 1:length(raw_fileIndex) %Loads every file in the index and saves as .set
    fileName = raw_files(raw_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_readegi([raw_directory_name, '\', NAME, '.raw'], [],[]);
    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [NAME, '.set'], [raw_directory_name '/.set']);
end

disp('*** All files successfully exported! ***');

%% 02 - Remove channel 130

set_directory_name = strcat(raw_directory_name,'/.set');
%cd(set_directory_name);

set_files = dir(fullfile(set_directory_name, '*.set'));

set_fileIndex = find(~[set_files.isdir]); %Creates index of all .set files

for i = 1:length(set_fileIndex) %Removes channel 130 from all files
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = set_files(set_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', set_directory_name);
    EEG = eeg_checkset( EEG );

    if EEG.nbchan>129
        EEG = pop_select( EEG, 'nochannel', [130]);
    end

    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', fileName , 'filepath', set_directory_name);
end

disp('*** Channel 130 was sucessfully removed! ***');

%% 03 - Change Channel Locations

for i = 1:length(set_fileIndex) %Loads all .set files and changes the channel locations according to the specified file
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = set_files(set_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', set_directory_name);
    EEG = eeg_checkset( EEG );

    EEG = pop_chanedit(EEG, 'load',{convertStringsToChars(pwd+"/GSN-HydroCel-129.sfp") 'filetype' 'autodetect'}); %%.sfp file must be in the working directory (same folder as .raw files)
    EEG.setname=[NAME, '_Loc'];
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', set_directory_name);
end

disp('*** Channel locations successfully updated! ***');

%% 04 - Batch Filtering

loc_files = dir(fullfile(set_directory_name, '*_Loc.set'));

loc_fileIndex = find(~[loc_files.isdir]);

for i = 1:length(loc_fileIndex) %Filters signal with a low-pass 30 Hz followed by high-pass 0.1 Hz
    fileName = loc_files(loc_fileIndex(i)).name;

    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', set_directory_name);
    EEG = eeg_checkset( EEG );

    EEG = pop_eegfilt( EEG, 0, 30, [], [0], 0, 0, 'fir1', 0); % Low-pass 30 Hz filter
    EEG.setname=[NAME, '_lp'];
    EEG = eeg_checkset( EEG );

    EEG = pop_eegfilt( EEG, 0.1, 0, [], [0], 0, 0, 'fir1', 0); %High-pass 0.1 Hz filter
    EEG.setname=[NAME, '_lp_hp'];
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', set_directory_name);
end

disp('*** All files successfully filtered! ***');

%% 05 - Delete bad channels

manual_steps = readtable('chave.xlsx');%chave.xlsx must be in the raw directory

hp_files = dir(fullfile(set_directory_name, '*_hp.set'));

hp_fileIndex = find(~[hp_files.isdir]);

for i = 1:length(hp_fileIndex) %For every file removes manually selected channels and trim intervals
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = hp_files(hp_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', set_directory_name);
    EEG = eeg_checkset( EEG );

    Intervalo = str2num(cell2mat(manual_steps.trim(i))); %Select trim interval
    Canais = str2num(cell2mat(manual_steps.electrodes(i))); %Select electrodes to remove

    if Canais > 0
        EEG = pop_select( EEG, 'time', Intervalo, 'nochannel', Canais);
    else
        EEG = pop_select( EEG, 'time', Intervalo);
    end

    EEG.setname=[NAME, '_del'];
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', set_directory_name);

    clear remover
end

disp('*** Bad channels sucessfully deleted! ***');

%% 06 - Batch ICA

del_files = dir(fullfile(set_directory_name, '*_del.set'));

del_fileIndex = find(~[del_files.isdir]);

for i = 1:length(del_fileIndex) %Performs ICA in all files
    fileName = del_files(del_fileIndex(i)).name;

    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', set_directory_name);
    EEG = eeg_checkset( EEG );

    EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
    EEG.setname=[NAME, '_ICA'];
    EEG = eeg_checkset (EEG); 

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', set_directory_name);
end

disp('*** ICA was sucessfully computed! ***');

%% 07 - Bad channel interpolation

cl_files = dir(fullfile(set_directory_name, '*_CL.set'));

EEG = pop_loadset('filename','00_CL.set','filepath',convertStringsToChars(set_directory_name));
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

cl_fileIndex = find(~[cl_files.isdir]);

for i = 2:length(cl_fileIndex) %Interpolates deleted channels
    fileName = cl_files(cl_fileIndex(i)).name;

    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', set_directory_name);
   
    EEG = eeg_checkset(EEG);
    
    EEG = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');
         
    EEG.setname=[NAME, '_interp'];
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', set_directory_name);
          
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, 0);
end
    
eeglab redraw; 
     
disp('*** Bad channels were sucessfully interpolated! ***');

%% 08 - Re-reference

interp_files = dir(fullfile(set_directory_name, '*_interp.set'));

interp_fileIndex = find(~[interp_files.isdir]);

for i = 1:length(interp_fileIndex) %Re-references
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = interp_files(interp_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);   

    EEG = pop_loadset( 'filename', fileName, 'filepath', set_directory_name);
    EEG = eeg_checkset( EEG );

    EEG = pop_reref(EEG, [] ,'keepref','on');
    EEG.setname=[NAME, '_Ref'];
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', set_directory_name);
end

disp('*** All files successfully processed! ***');