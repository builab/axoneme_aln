% Check host name
[s, host] = unix('env | grep ''HOSTNAME=''');

% Add path tombox
addpath(genpath('/mol/ish/Data/programs/tom'))

% Add path ACE (CTF correction)
addpath(genpath('/mol/ish/Data/programs/ace_2.3.1'))

% Addpath library
addpath(genpath('/mol/ish/Data/Huy_tmp/matlab_dir'))



