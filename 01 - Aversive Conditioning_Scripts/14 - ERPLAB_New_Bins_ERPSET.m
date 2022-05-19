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
files = dir(fullfile(directory_name, '*_ERP.erp'));

%Create new directory to save .set files
%mkdir(directory_name, 'ERPLAB');

%Creates index of all the .asc files in the directory
fileIndex = find(~[files.isdir]);


%Loads each .avr files and saves them as .set
for i = 1:length(fileIndex)

fileName = files(fileIndex(i)).name;
[PATH, NAME, EXT] = fileparts(fileName);

ERP = pop_loaderp( 'filename', fileName, 'filepath',directory_name);


ERPNEWNAME=[NAME, '_NewBin'];

%%%%%%% Function Assignement %%%%%%%%

ERP = pop_binoperator( ERP, {  'nb1 = wavgbin(1,2,3,4,5,6) label Aversive',  'nb2 = wavgbin(7,8,9) label Non-Aversive',  'nb3 = wavgbin(1,4) label AversiveB1',...
  'nb4 = wavgbin(2,5) label AversiveB2',  'nb5 = wavgbin(3,6) label AversiveB3',  'nb6 = b7 label Non-AversiveB1',  'nb7 = b8 label Non-AversiveB2', ...
  'nb8 = b9 label Non-AversiveB3', 'nb9 = b10 label Ext_Aversive', 'nb10 = wavgbin(11,12) label Ext_NonAversive'});

ERP = pop_savemyerp(ERP, 'erpname', ERPNEWNAME, 'filename', [ERPNEWNAME, '.erp'], 'filepath', directory_name, 'Warning',...
 'on');

eeglab redraw;


end

%Hooray!
disp('*** All files successfully processed! ***');
