function [F, errors] = compi_get_F_hgf(files)
%--------------------------------------------------------------------------
% Function that extracts LME of HGF models.
% 
% Input:
%   files       -> Cell array with #subjects rows and #models columns. 3rd
%                  dimension may be used for noise levels in simulations.
%
% Output:
%   F           -> Matrix with F values and the same dimensions as files.
%--------------------------------------------------------------------------


%% Get F
fprintf('\n Collecting F...');

F = NaN(size(files));
errors = cell(0);
num_err = 1;

for d1 = 1:size(F,1) % 1st Dimension: Subjects
    for d2 = 1:size(F,2) % 2nd Dimension: Models
        for d3 = 1:size(F,3) % 3rd Dimension: Noise values for simulations
            try % Load model file
                load(files{d1,d2,d3});
                try
                    F(d1,d2,d3) = est.F;
                catch
                    F(d1,d2,d3) = est.optim.LME;
                end
                clear est
            catch
                errors{num_err} = files{d1,d2,d3};
                num_err = num_err +1;
            end 
        end
    end
end


%% Error messages
if isempty(errors)
    fprintf('\n No errors occured.');
else
    for i = 1:length(errors)
        if i == 1
            warning(['Errors occured: ' errors{i}])
        else
            warning(errors{i})
        end
    end
end



