function rewrite_hgf_model_file(old_model, new_model, old_file, new_file, old_dir, new_dir)


%old_file = 'MS14_dmpad_sutton';
%new_file = 'MS15_dmpad_sutton';


old_file = fullfile(old_dir, [old_file '.m']);
new_file = fullfile(new_dir,[new_file '.m']);

fid_old = fopen(old_file,'r');
fid_new = fopen(new_file,'w');


tline = fgets(fid_old);
while ischar(tline)
    
    tline = strrep(tline,old_model,new_model);
    fprintf(fid_new,'%s',tline);
    tline = fgets(fid_old);
end

fclose(fid_old);
fclose(fid_new);

end