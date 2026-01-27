function create_motion_reg(subIDs)

[path,vars]    = get_study_specs;
baseDir        = path.mriDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;

for sub = 1:nSubs
    subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    physioDir   = fullfile(path.physioDir,sprintf('sub%02d',subIDs(sub)),'noise_reg');
    for run = 1:nRuns
        runDir       = fullfile(subDir,sprintf('run%d',run),'brain');
        rpFile       = load(spm_select('FPList',runDir,spm_file(sprintf(vars.rawEpiID,subIDs(sub),run),'prefix','rp_','ext','txt')));

        % norm the file (for better comparison with other betas)
        SD           = std(rpFile,1);
        mu           = mean(rpFile, 1);
        normed_vals  = (rpFile-mu) ./ SD;
        % square the normed values
        squared_vals = normed_vals.^2;
        % take derivative of values, zeros as first value
        %difference between (t) - (t-1) = slope
        derivs = diff(normed_vals);
        derivs = [zeros(1,size(derivs,2)); derivs];
        % mean correct the derivatives
        SD           = std(derivs);
        mu           = mean(derivs, 1);
        cor_derivs   = (derivs-mu)./ SD;
        % square the mean corrected derivs
        squared_derivs = cor_derivs .^2;
        motion =   [normed_vals, squared_vals, derivs, squared_derivs];
        outFilename = sprintf(vars.noiseFile,subIDs(sub),'motion',run);
        save(fullfile(physioDir,outFilename),'motion');
    end
end
end