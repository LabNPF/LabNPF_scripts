%% 00 - Global variables

channel_interp = '00_CL.set'; %name of the .set file for the electrode location for channel interpolation. Default: 00_CL.set
excel_filename = 'key.xlsx'; %Excel file with the trim intervals and channels removed. Default: key.xlsx
low_pass = 30; %Low-pass filter cut-off frequency. Default: 30 Hz
high_pass = 0.1; %High-pass filter cut-off frequency. Default: 0.1 Hz
chanloc = "/GSN-HydroCel-129.sfp"; %.sfp file with electrode location. Default: "/GSN-HydroCel-129.sfp"
ref = []; %Reference channel. Default: [] (average of all channels)
fid = fopen('log.txt','a+'); %Creates or opens the log 
fclose(fid);

directory_name = uigetdir; %Select directory of the files
cd(directory_name); %Change working directory
raw_directory_name = strcat(directory_name,'/RAW');
raw_files = dir(fullfile(raw_directory_name, '*.raw'));

mkdir(directory_name, '/EEG_Set'); %Create new directory to save .set files
EEG_directory_name = strcat(directory_name,'/EEG_Set');

%% 01 - Autoexport egi to .set

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab; %Open EEGLab

raw_fileIndex = find(~[raw_files.isdir]); %Creates index of files in directory

for i = 1:length(raw_fileIndex) %Loads every file in the index and saves as .set
    fileName = raw_files(raw_fileIndex(i)).name;
    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_readegi([raw_directory_name, '\', NAME, '.raw'], [],[]);
    EEG = eeg_checkset(EEG);
    eeglab redraw;

    EEGOUT = pop_saveset(EEG,  [NAME, '.set'], [directory_name '/EEG_Set']);
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Exported EGI to .set; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
end

disp('*** All files successfully exported! ***');

%% 02 - Remove channel 130

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

set_files = dir(fullfile(EEG_directory_name, '*.set'));

set_fileIndex = find(~[set_files.isdir]); %Creates index of all .set files

for i = 1:length(set_fileIndex) %Removes channel 130 from all files
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = set_files(set_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
    EEG = eeg_checkset( EEG );
    old_EEG = EEG;

    if EEG.nbchan>129
        EEG = pop_select( EEG, 'nochannel', [130]);
    end

    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', fileName , 'filepath', EEG_directory_name);
    
    if EEG.nbchan > 129
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Removed channel 130; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
end

disp('*** Channel 130 was sucessfully removed! ***');

%% 03 - Change Channel Locations

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

for i = 1:length(set_fileIndex) %Loads all .set files and changes the channel locations according to the specified file
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = set_files(set_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
    EEG = eeg_checkset( EEG );

    old_EEG = EEG;
    
    EEG = pop_chanedit(EEG, 'load',{convertStringsToChars(pwd+chanloc) 'filetype' 'autodetect'}); %%.sfp file must be in the working directory (same folder as .raw files)
    EEG.setname=[NAME, '_Loc'];
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', EEG_directory_name);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Changed channel locations; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
end

disp('*** Channel locations successfully updated! ***');

%% 04 - Batch Filtering

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

loc_files = dir(fullfile(EEG_directory_name, '*_Loc.set'));

loc_fileIndex = find(~[loc_files.isdir]);

for i = 1:length(loc_fileIndex) %Filters signal with a low-pass 30 Hz followed by high-pass 0.1 Hz
    fileName = loc_files(loc_fileIndex(i)).name;

    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
    EEG = eeg_checkset( EEG );

    old_EEG = EEG;
    
    EEG = pop_eegfilt( EEG, 0, low_pass, [], [0], 0, 0, 'fir1', 0); % Low-pass 30 Hz filter
    EEG.setname=[NAME, '_lp'];
    EEG = eeg_checkset( EEG );
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Applied low-pass filter, %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);

    EEG = pop_eegfilt( EEG, high_pass, 0, [], [0], 0, 0, 'fir1', 0); %High-pass 0.1 Hz filter
    EEG.setname=[NAME, '_lp_hp'];
    EEG = eeg_checkset( EEG );
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Applied high-pass filter; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', EEG_directory_name);
end

disp('*** All files successfully filtered! ***');

disp('Manual step: determine trim intervals and channels to be deleted.');
input('Press "Enter" to continue...','s');

%% 05 - Delete bad channels

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

manual_steps = readtable(excel_filename); 

hp_files = dir(fullfile(EEG_directory_name, '*_hp.set'));

hp_fileIndex = find(~[hp_files.isdir]);

for i = 1:length(hp_fileIndex) %For every file removes manually selected channels and trim intervals
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = hp_files(hp_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
    EEG = eeg_checkset( EEG );

    old_EEG = EEG;
    
    Intervalo = str2num(cell2mat(manual_steps.trim(i))); %Select trim interval
    Canais = str2num(cell2mat(manual_steps.electrodes(i))); %Select electrodes to remove

    if Canais > 0
        EEG = pop_select( EEG, 'time', Intervalo, 'nochannel', Canais);
    else
        EEG = pop_select( EEG, 'time', Intervalo);
    end

    EEG.setname=[NAME, '_del'];
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', EEG_directory_name);

    clear remover
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Deleted manually selected channels; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
end

disp('*** Bad channels sucessfully deleted! ***');

%% 06 - Batch ICA

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

del_files = dir(fullfile(EEG_directory_name, '*_del.set'));

del_fileIndex = find(~[del_files.isdir]);

for i = 1:length(del_fileIndex) %Performs ICA in all files
    fileName = del_files(del_fileIndex(i)).name;

    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
    EEG = eeg_checkset( EEG );
    
    old_EEG = EEG;

    EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
    EEG.setname=[NAME, '_ICA'];
    EEG = eeg_checkset (EEG); 

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', EEG_directory_name);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Computed ICA; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
end

disp('*** ICA was sucessfully computed! ***');
disp('Manual step: delete bad channels based on the ICA. Output file must be named *_CL.set, where * is the current name of the file');
input('Press "Enter" to continue...','s');

%% 07 - Bad channel interpolation

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

cl_files = dir(fullfile(EEG_directory_name, '*_CL.set'));

EEG = pop_loadset('filename',channel_interp,'filepath',convertStringsToChars(EEG_directory_name));
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

cl_fileIndex = find(~[cl_files.isdir]);

for i = 2:length(cl_fileIndex) %Interpolates deleted channels
    fileName = cl_files(cl_fileIndex(i)).name;

    [PATH, NAME, EXT] = fileparts(fileName);

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
   
    EEG = eeg_checkset(EEG);
    
    old_EEG = EEG;
    
    EEG = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');
         
    EEG.setname=[NAME, '_interp'];
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', EEG_directory_name);
          
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, 0);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Interpolated deleted channels; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
end
    
eeglab redraw; 
     
disp('*** Bad channels were sucessfully interpolated! ***');

%% 08 - Re-reference

if exist('channel_interp','var') == 0
    error('Global variables undefined');
end

eeglab redraw;

interp_files = dir(fullfile(EEG_directory_name, '*_interp.set'));

interp_fileIndex = find(~[interp_files.isdir]);

for i = 1:length(interp_fileIndex) %Re-references
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    fileName = interp_files(interp_fileIndex(i)).name;

    [PATHSTR,NAME,EXT] = fileparts(fileName);   

    EEG = pop_loadset( 'filename', fileName, 'filepath', EEG_directory_name);
    EEG = eeg_checkset( EEG );
    
    old_EEG = EEG;

    EEG = pop_reref(EEG, ref ,'keepref','on');
    EEG.setname=[NAME, '_Ref'];
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', EEG_directory_name);
    
    if isequaln(old_EEG,EEG)
       error('Something went wrong...');
    end
    
    fid = fopen('log.txt','a+');
    fprintf(fid, 'Subject: %d ; Re-referenced; %s\n',i,datestr(now,'HH:MM:SS.FFF dd/mm/yy'));
    fclose(fid);
    
end

disp('*** All files successfully processed! ***');