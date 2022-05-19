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
files = dir(fullfile(directory_name, '*_NewBin.erp'));

%Create new directory to save .set files
%mkdir(directory_name, 'ERPLAB');

%Creates index of all the .asc files in the directory
fileIndex = find(~[files.isdir]);



for i = 1:length(fileIndex)

fileName = files(fileIndex(i)).name;
[PATH, NAME, EXT] = fileparts(fileName);

ERP = pop_loaderp( 'filename', fileName, 'filepath',directory_name);


ERPNEWNAME=[NAME, '_AvgChan'];

%%%%%%% Function Assignement %%%%%%%%

ERP = pop_erpchanoperator( ERP, {'ch130 = (ch4+ch5+ch10+ch11+ch12+ch16+ch18+ch19)/8 label AvgFZ', 'ch131 = (ch19+ch20+ch23+ch24+ch27+ch28)/6 label AvgF3',...
  'ch132 = (ch3+ch4+ch117+ch118+ch123+ch124)/6 label AvgF4', 'ch133 = (ch7+ch31+ch55+ch80+ch106+ch129)/6 label AvgCZ', 'Ch134 = (ch35+ch29+ch30+ch37+ch42+ch41+ch36)/7 label AvgC3',...
  'Ch135 = (ch104+ch105+ch111+ch110+ch103+ch93+ch87)/7 label AvgC4', 'Ch136 = (ch61+ch62+ch67+ch72+ch77+ch78)/6 label AvgPZ', 'Ch137 = (ch52+ch51+ch47+ch42+ch53+ch60+ch59)/7 label AvgP3',...
  'Ch138 = (ch92+ch86+ch93+ch98+ch97+ch91+ch85)/7 label AvgP4'}, 'ErrorMsg', 'popup', 'Warning', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERP = pop_savemyerp(ERP, 'erpname', ERPNEWNAME, 'filename', [ERPNEWNAME, '.erp'], 'filepath', directory_name, 'Warning',...
 'on');

eeglab redraw;


end

%Hooray!
disp('*** All files successfully processed! ***');
