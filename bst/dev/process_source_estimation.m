function process_source_estimation(iStudy)





%% ===== MINIMUM NORM =====
% Compute minnorm sources for all recordings file in study
%for i = 1:length(sStudy.Data)
    %iData = i;
    % Model options: For the meaning of the parameters, please refer to file script_minnorm.m
    OPTIONS.Tikhonov = 10;
    OPTIONS.FFNormalization = 1;
    OPTIONS.ComputeKernel = 1;
    OPTIONS.UseNoiseCov = 1;
    OPTIONS.Comment = 'MN: shared kernel';

    % Start computation
    script_minnorm(iStudy, [], 'MN: shared kernel');

disp('Done.');
