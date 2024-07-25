function copy_model_space

ms = 9;
ms_new = 14;

root =  'C:\projects\COMPI\behav\FirstLevel\hgf';

% Get models
options = compi_ioio_options('ioio','hgf_comp','all');
options = compi_ioio_hgf_options(options, ms);
prc_models = options.hgf.prc_models;
obs_models = options.hgf.obs_models;


for iM = 1:size(prc_models,2)
    stripped_model_name = erase(prc_models{iM}(strfind(prc_models{iM},'_'):end),...
        '_config');
    
    old_model = erase(prc_models{iM},'_config');
    new_model = sprintf('MS%d%s', ms_new, stripped_model_name);
    
    path = fullfile(root,'prc_models');
    
    new_dir = fullfile(path,new_model);
    old_dir = fullfile(path,old_model);
    
    cd(root);
    mkdir(new_dir);
    
    
    model_files = ls(old_dir);
    for i = 3:size(model_files,1)
        old_file = strtrim(model_files(i,:));
        old_file = old_file(1:(end-2));
        new_file = strrep(old_file,old_model,new_model);
        
        rewrite_hgf_model_file(old_model, new_model, old_file, new_file, old_dir, new_dir)
        
    end
    
    
end



for iM = 1:size(obs_models,2)
    stripped_model_name = erase(obs_models{iM}(strfind(obs_models{iM},'_'):end),...
        '_config');
    
    old_model = erase(obs_models{iM},'_config');
    new_model = ['MS' num2str(ms_new) stripped_model_name];
    
    path = fullfile(root,'obs_models');
    
    new_dir = fullfile(path,new_model);
    old_dir = fullfile(path,old_model);
    
    cd(root);
    mkdir(new_dir);
    
    
    model_files = ls(old_dir);
    for i = 3:size(model_files,1)
        old_file = strtrim(model_files(i,:));
        old_file = old_file(1:(end-2));
        new_file = strrep(old_file,old_model,new_model);
        
        rewrite_hgf_model_file(old_model, new_model, old_file, new_file, old_dir, new_dir)
    end
end