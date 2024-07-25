function loop_analyze_hgf_local(options)

for idCell = options.subjects.all
            id = char(idCell);
    dmpad_create_behav_regressors(id, options)
end

end