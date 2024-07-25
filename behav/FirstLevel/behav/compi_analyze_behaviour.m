function full_behavior = compi_analyze_behaviour(id, options)

dobehavVariables = ismember('behaviour', options.behav.pipe.executeStepsPerSubject);


% Extracts behavioural variables of a given subject and save them
if dobehavVariables
    full_behavior = compi_ioio_get_behavior(id, options);
end


end
