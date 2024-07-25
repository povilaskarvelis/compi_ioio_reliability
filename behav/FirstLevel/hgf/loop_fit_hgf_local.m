function loop_fit_hgf_local(options)
%--------------------------------------------------------------------------
% Function that fits HGF models for all subjects.
%--------------------------------------------------------------------------




%% Get subjects and models
subjects = options.subjects.all;
models   = options.hgf.models;

% Initialize
errors = cell(0);
i_err  = 1;
now = datestr(datetime,'ddmmyy_HHMM');
cd(fullfile(options.roots.log));
diary(['logfile_hgf_inversion_' now '.log'])


%% Cycle through subjects
for s = 1:length(subjects)
    
    % Get subject details
    id = subjects{s};
    fprintf('\n\n-------------\nSubject: %s\n-------------\n', id);
    details = compi_get_subject_details(id, options);
    mkdir(details.dirs.results_hgf);    
    files = details.files.behav;
    
    
    %% Cycle through files
    for i_file = 1:length(files)
        
        % Get modality
        [~, file_name1] = fileparts(files{i_file}{1});
        [~, file_name2] = fileparts(files{i_file}{2});
        
        %-------------------
        % Get data
        %-------------------
        [data, behav_measures] = ...
            compi_ioio_get_data(files{i_file}, details, options);
        
        
        %% Cycle through models
        for i_m = 1:length(models)
            m = models(i_m);
            
            % Get model names and print some output
            [prc_model, obs_model] = get_obs_and_prc_model(m,options);
            fprintf('\n\n-------------\nModel: %d\n-------------\n', m);
            fprintf('Files: %s, %s\n', file_name1,file_name2);
            fprintf('Perceptual model: %s\nObservational model: %s\n\n',...
                prc_model,obs_model);
            
            try
                %-------------------
                % Invert
                %-------------------
                [est, perf] = train_hgf(data, prc_model, obs_model,...
                    options.hgf.seeds);
                
                % Save
                save(details.files.hgf_models{i_file,i_m},...
                    'est','perf','behav_measures');
                
                %-------------------
                % Plot diagnostic
                %-------------------
                [fh_traj, fh_corr] = plot_hgf(est, perf, options.task.vol_struct,'off');
               
                % Save figures
                if length(files)>1
                    switch i_file                  
                    case 1  
                        saveas(fh_traj,...
                            fullfile(options.roots.diag_hgf,['m' num2str(m)],'traj',...
                            [id '_eeg.png']));
                        close(fh_traj); clear fh_traj;

                        saveas(fh_corr,...
                            fullfile(options.roots.diag_hgf,['m' num2str(m)],'corr',...
                            [id '_eeg.png']));
                        close(fh_corr); clear fh_corr;
                        case 2
                        saveas(fh_traj,...
                            fullfile(options.roots.diag_hgf,['m' num2str(m)],'traj',...
                            [id '_fmri.png']));
                        close(fh_traj); clear fh_traj;

                        saveas(fh_corr,...
                            fullfile(options.roots.diag_hgf,['m' num2str(m)],'corr',...
                            [id '_fmri.png']));
                        close(fh_corr); clear fh_corr;
                    end     
                else
                    saveas(fh_traj,...
                        fullfile(options.roots.diag_hgf,['m' num2str(m)],'traj',...
                        [id '.png']));
                    close(fh_traj); clear fh_traj;

                    saveas(fh_corr,...
                        fullfile(options.roots.diag_hgf,['m' num2str(m)],'corr',...
                        [id '.png']));
                    close(fh_corr); clear fh_corr;
                end
                
            catch err
                errors{i_err} = err;
                i_err = i_err +1;
                warning(sprintf('Error occured for subject %s and model %d.', id, m));
                warning(err.message)
            end
            
        end
    end
end

save(fullfile(options.roots.err,...
    ['errors_hgf_inversion_' now '.mat']),'errors');
diary off
cd(options.roots.code)

