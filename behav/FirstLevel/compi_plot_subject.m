function compi_plot_subject(id, options)
details = compi_ioio_subjects(id, options);
responseModels   = options.model.responseModels;

diagnostics = false;

for iRsp=1:numel(responseModels)
    switch options.task.modality
        case 'eeg'
            load(fullfile(details.behav.eeg.pathResults,[details.behav.invertIOIOCOMPIName, ...
                options.model.responseModels{iRsp},'.mat']), 'est_COMPI','-mat');
        case 'fmri'
            load(fullfile(details.behav.eeg.pathResults,[details.behav.invertIOIOCOMPIName, ...
                options.model.responseModels{iRsp},'.mat']), 'est_COMPI','-mat');
    end
    
    switch options.model.perceptualModels
        case 'tapas_rw_binary'
            tapas_rw_binary_plotTraj(est_COMPI);
        case 'tapas_hgf_binary'
            sim_COMPI = tapas_simModel(est_COMPI.u, options.model.winningPerceptual, ...
                est_COMPI.p_prc.p, options.model.winningResponse, est_COMPI.p_obs.p);
            temp  = (est_COMPI.y == sim_COMPI.y);
            sim_actual_y = double(temp');
            compi_hgf_binary_plotTraj(est_COMPI,sim_COMPI, sim_actual_y,options);
        case 'tapas_hgf_ar1_binary'
            tapas_hgf_ar1_binary_plotTraj(est_COMPI);
    end
    
    if diagnostics == true
        tapas_fit_plotCorr(est_COMPI);
    end
    
end
end