% Check host name
[s, aaDir] = unix('env | grep ''AA_DIR=''');

aaDir = regexprep(aaDir, 'AA_DIR=', '');
aaDir = regexprep(aaDir, '\n$', '');

% Addpath library

%addpath(genpath([aaDir '/matlab_script']))
addpath(genpath([aaDir '/tom']))

addpath(genpath([aaDir '/matlab']))


% Add path tombox
%addpath(genpath('/struct/mbeck/bui/programs/tom_dev'))



% Add extra library
%addpath(genpath('/struct/mbeck/bui/programs/matlab_script'));


