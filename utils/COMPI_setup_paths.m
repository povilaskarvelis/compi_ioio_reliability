function COMPI_setup_paths()
% restores default paths, add project paths including SPM (but without
% sub-folders), sets up batch editor


pathProject = fileparts(mfilename('fullpath'));

% remove all other toolboxes
restoredefaultpath;

% add project path with all sub-paths
addpath(genpath(pathProject));


% remove SPM subfolder paths 
pathSpm = fileparts(which('spm'));
rmpath(genpath(pathSpm));
addpath(pathSpm);

% NOTE: NEVER add SPM with subfolders to your path, since it creates
% conflicts with Matlab core functions, e.g., uint16
% remove subfolders of SPM, since it is recommended,
% and fieldtrip creates conflicts with Matlab functions otherwise

% set SPM settings
COMPI_setup_spm;

% remove paths to toolboxes
rmpath(genpath(fullfile(pathProject,'Toolboxes', 'VBA')));
rmpath(genpath(fullfile(pathProject,'Toolboxes', 'tapas_6.0')));
rmpath(genpath(fullfile(pathProject,'Toolboxes', 'HGF_3.0')));
rmpath(genpath(fullfile(pathProject,'behav','FirstLevel','hgf','utils','HGF_tutorial')));

% specify paths to toolboxes
paths.root   = fileparts(mfilename('fullpath'));
paths.tools  = fullfile(paths.root,'Toolboxes');
paths.torqc  = fullfile(paths.tools, 'TorQC');
paths.uniqc  = fullfile(paths.tools, 'UniQC');
paths.spm    = fullfile(paths.tools, 'spm12');
paths.tapas  = fullfile(paths.tools, 'tapas_6.0');
paths.physio = fullfile(paths.tapas, 'PhysIO');
paths.physioCode = fullfile(paths.physio, 'code');

% now we can use the convenience tool to not recursively add SPM, and also not the released UniOQ version within TAPAS
generatedPath = tapas_uniqc_genpath_exclude_subdirs(paths.torqc, {paths.spm, '\.git', fullfile(paths.tapas, 'UniQC')});
addpath(generatedPath);
addpath(paths.spm);

rmpath(genpath(fullfile(paths.spm, 'external', 'fieldtrip', 'external')));

addpath(genpath(paths.uniqc));

% add physio toolbox
addpath(genpath(paths.physio))
tapas_physio_create_spm_toolbox_link(paths.physioCode);



