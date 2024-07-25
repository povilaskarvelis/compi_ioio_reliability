function options = compi_ioio_options(task, modality, groups, preprocStrategyValueArray, firstLevelDesignName)
%--------------------------------------------------------------------------
% Sets various options for the analysis
%
%--------------------------------------------------------------------------


%% Defaults
if nargin < 1
    % Choose between: 'mmn', 'ioio', 'wm'
    task = 'ioio';
end

if nargin < 2
    % Choose between: 'eeg','fmri', 'behav' (only behavior from first task,
    % if applicable), 'behav_all', 'phase', 'hgf_comp'
    modality = 'fmri';
end

if nargin < 3
    % Choose between: 'all', 'hc', 'fep', 'chr'
    groups = 'hc';
end

if nargin < 4
    preprocStrategyValueArray = [2 1 4 2 1 1 1 1 2];
end

if nargin < 5
    firstLevelDesignName = 'Default';
end


%% Set user roots
[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Andreea
    case 'drea'
        options.roots.project = '/Users/drea/Documents/IOIO_AMBIZIONE/COMPI';
        options.roots.code    = '/Users/drea/Documents/IOIO_AMBIZIONE/COMPI/code';
        options.roots.config  = '/Users/drea/Documents/IOIO_AMBIZIONE/COMPI/code/configs';
        options.roots.data    = '/Users/drea/Documents/IOIO_AMBIZIONE/COMPI/data';
        
    % Daniel Lenovo Carbon X1 (old PC)
    case 'desktop-pllks1m\daniel'
        options.roots.project = 'E:\COMPI';
        options.roots.code    = 'C:\COMPI';
        options.roots.config  = 'C:\COMPI\configs';
        options.roots.data    = 'E:\COMPI\data';
        
    % Daniel Lenovo P1 (new PC)
    case 'laptop-0jhjt7kf\danie'
        options.roots.project = 'D:\COMPI';
        options.roots.code    = 'C:\projects\COMPI';
        options.roots.config  = 'C:\projects\COMPI\configs';
        options.roots.data    = 'D:\COMPI\data';
        
    case 'u\karve'
        options.roots.project = 'E:\COMPI';
        options.roots.code    = 'C:\Users\karve\Dropbox\Postdoc\Studies\COMPI\code';
        options.roots.config  = 'C:\Users\karve\Dropbox\Postdoc\Studies\COMPI\code\configs';
        options.roots.data    = 'E:\COMPI\data';

end

options.roots.toolboxes = fullfile(options.roots.code ,'Toolboxes');

%% Set options

% Choose between: 'all', 'hc', 'fep', 'chr'
options.subjects.groups = groups; 

% Choose between: 'mmn', 'ioio', 'wm'
options.task.type = task;

% Choose between: 'eeg','fmri', 'phase' (only behavior from first task, 
% if applicable), 'test_retest'
options.task.modality = modality;  

% Parallelization
options.parallelization.cluster = 'none';
options.parallelization.doRunOnArton = false; % parallelization on other cluster with ssd scratch disk

% Result folder roots
switch modality
    case 'eeg'
    options.roots.results = fullfile(options.roots.project,'results', task, modality,...
        sprintf('preproc_strategy_%d_%d_%d_%d_%d_%d_%d_%d_%d', preprocStrategyValueArray));
    case 'fmri'
        options.roots.results = fullfile(options.roots.project,'results', modality);
        options.roots.results = fullfile(options.roots.project,'results', modality);
    otherwise
        options.roots.results = fullfile(options.roots.project,'results', task, modality);
        options.roots.results = fullfile(options.roots.project,'results', task, modality);
end

% Logfile folder roots
options.roots.log = fullfile(options.roots.results,'logfiles');

% Error folder roots
options.roots.err = fullfile(options.roots.results,'errors');

% Create folders
mkdir(options.roots.results);
mkdir(options.roots.log);
mkdir(options.roots.err);

% Specify task options
options = compi_ioio_task_options(options);

% Specify behavioral options
options = compi_ioio_behav_options(options);

% Specify HGF options
switch modality
    case 'hgf_comp'
        model_space = 1;
    case 'phase'
        model_space = 1;
    otherwise
        model_space = 1;
end
options = compi_ioio_hgf_options(options, model_space);


%% Specify EEG options
switch options.task.modality
    case 'eeg'
        switch task
            case 'ioio'
                options = compi_ioio_eeg_options(options, ...
                    preprocStrategyValueArray, firstLevelDesignName);
            case 'mmn'
                options = compi_mmn_eeg_options(options);
        end
end


%% Get subjects

% Enter new subjects here, also include in missingness switch and eeg first
options = compi_ioio_subject_options(options);



