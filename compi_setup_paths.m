function compi_setup_paths
%--------------------------------------------------------------------------
% Sets up paths
%--------------------------------------------------------------------------


%% Main
path_project = fileparts(mfilename('fullpath')); % saves the path for this proeject
restoredefaultpath; % remove all other paths to avoid conflicts
addpath(genpath(path_project)); % add project path with all sub-paths

% Removes VBA toolbox and tapas from path 
% (will be added as needed to avoid conflicts)
rmpath(genpath(fullfile(path_project,'Toolboxes', 'VBA')));
rmpath(genpath(fullfile(path_project,'Toolboxes', 'HGF_3.0')));
cd(path_project);