function run_spm_parallel(matlabbatch,nCores)
% basically lukas function to parallelize SPM preprocessing
% relies on parallel computing toolbox
% start parallel pool if there is none, splot matlabbatch and run parallel

if ~license('test', 'Distrib_Computing_Toolbox')
    run_spm_multiple(matlabbatch,nCores); % starts multiple matlabs via system calls
else
    start_pool_conditionally(nCores);
    loop_procs = split_vect(matlabbatch,nCores);
    
    spm_path = fileparts(which('spm'));
    
    parfor worker = 1:nCores
        %for worker = 1:nCores
        matlabbatch = vec(loop_procs{worker})';
        %save(sprintf('%d_test.mat',worker),'matlabbatch');
        do_one_batch(matlabbatch);
    end
end
end
function do_one_batch(input)
spm('defaults','FMRI');
spm_jobman('initcfg');
spm_jobman('run', input);
end

function pool = start_pool_conditionally(nWorkers)
% check if parallel pool already runs if not start a new one

pool = gcp('nocreate');

if isempty(pool)
    pool = parpool(nWorkers);
elseif pool.NumWorkers ~= nWorkers
    fprintf('Wrong number of workers. Starting again.\n');
    delete(pool);
    pool = parpool(nWorkers);
else
    fprintf('Pool with %d worker(s) already running.\n', nWorkers);
end

end

function chuckCell = split_vect(v,n)
% splits vector into number of n chunks of equal size
% based on lukas function, based on
% http://code.activestate.com/recipes/425044

chuckCell  = {};
%vectLength = numel(v);
vectLength = size(v,2);
splitsize  = 1/n*vectLength;

for i = 1:n
    idxs = [floor(round((i-1)*splitsize)):floor(round((i) * splitsize))-1]+1;
    chuckCell{end + 1} = v(:,idxs);
end

end

function vx = vec(X)
% transform array X into a column vector

% avoid weirdly sized empty vector
if isempty(X)
    vx = [];
    return;
end

% return vectorized input
vx = full(X(:));

end