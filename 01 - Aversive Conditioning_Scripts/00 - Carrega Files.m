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
files = dir(fullfile(directory_name, '*_Ref.set'));

%Creates index of all the .set files in the directory
fileIndex = find(~[files.isdir]);


for i = 1:length(fileIndex)
fileName = files(fileIndex(i)).name;

[PATH, NAME, EXT] = fileparts(fileName);

%STUDY = []; CURRENTSTUDY = []; ALLEEG = []; EEG=[]; CURRENTSET=[];

         EEG = pop_loadset( 'filename', fileName, 'filepath', directory_name);
   
         EEG = eeg_checkset(EEG);
    
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        
        %EEG = pop_saveset( EEG,  'filename', 'filepath', directory_name);
        
        %[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);

        
    end;
    
    eeglab redraw; 
     
    %Hooray!
    disp('*** All files successfully processed! ***');
