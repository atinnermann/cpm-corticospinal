function extract_segment(epiFiles,cmFile,cFiles,thresh,ex_var,outName) %templ2T1

V_epi            = spm_vol(epiFiles);
V_wmean_scan     = spm_vol(cmFile);
% N_back_scan      = nifti(templ2T1);

for i=1:numel(cFiles)
    [~,name{i},~] = fileparts(cFiles{i});
    V_part     = spm_vol(char(cFiles{i}));
    xY(i).name = name{1};
    xY(i).spec = V_part;
    xY(i).def  = 'mask';
    xY(i).xyz  = Inf;
    xY(i).thresh  = thresh(i);

    data{i}    = spm_read_vols(V_part); %make data available in RAM for spm_erode
    V_part.dt  = [spm_type('float64') spm_platform('bigend')];
    V_part.dat = spm_erode(data{i}); %erode once
    V_part.pinfo(1) = 1; % scale factor dtype now double so = 1
    V_part.pinfo(3) = 0; % read from .dat

    yy         = get_roi_ts(xY(i), V_epi, V_wmean_scan, V_part); %N_back_scan
    yy         = yy(:,any(yy)); % prune out zero time-series

    wmcsf{i} = get_pcs(yy,ex_var); % get principal components
    
end

%-Save
%==========================================================================
save(outName,'wmcsf');
