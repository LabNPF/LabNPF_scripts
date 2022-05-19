%%%%%%%%%Cria Study%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%Tiago O. Paiva%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Agosto 2012%%%%%%%%%%%%%%%%%%%%%%%%




eeglab;

% % Set memory options:   
% pop_editoptions( 'option_storedisk', 1, 'option_savetwofiles', 1, ...
%     'option_saveica', 1, 'option_single', 0, 'option_memmapdata', ...
%      0, 'option_computeica', 1, 'option_scaleicarms', 0, ...
%     'option_rememberfolder', 1);  

%Get directory name to search for files
directory_name = uigetdir;
files = dir(fullfile(directory_name, '*_CL.set'));


EEG = pop_loadset('filename','00_CL.set','filepath','D:\Tiago O. Paiva\07 - PhD\01 - RawData\01 - Aversive Conditioning\.set');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

%Creates index of all the .set files in the directory
fileIndex = find(~[files.isdir]);


for i = 2:length(fileIndex)
fileName = files(fileIndex(i)).name;

[PATH, NAME, EXT] = fileparts(fileName);

%STUDY = []; CURRENTSTUDY = []; ALLEEG = []; EEG=[]; CURRENTSET=[];

         EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
   
         EEG = eeg_checkset(EEG);
    
         EEG = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');
         
          EEG.setname=[NAME, '_interp'];
          EEG = eeg_checkset(EEG);
          EEG = pop_saveset( EEG,  'filename', [EEG.setname, '.set'] , 'filepath', directory_name);
          
          
          [ALLEEG EEG] = eeg_store(ALLEEG, EEG, 0);
                     
           
       
            
    end;
    
    eeglab redraw; 
     
    %Hooray!
    disp('*** All files successfully processed! ***');
