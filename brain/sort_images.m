function sort_images(subIDs,rmDummy,rmLast)

[path,vars]  = get_study_specs;
baseDir      = path.rawData;
nSubs        = length(subIDs);
nRuns        = vars.nRuns;
nDummy       = vars.nDummy*2;
nScans       = vars.nScans*2;

folder  = {'brain';'spinal'};

if nargin < 3
    rmLast = 0;
end

for sub = 1:nSubs
    subID      = subIDs(sub);
    subDir     = fullfile(baseDir,sprintf('sub%02d',subID));
    for run = 1:nRuns
        runDir = fullfile(subDir,sprintf('run%d',run));
        
        %create subfolder
        for m = 1:length(folder)
            mkdir(runDir,folder{m});
        end
        
        %remove dummy scans
        if rmDummy
            files = spm_select('FPList',runDir,'.*.nii');
            for f = 1:nDummy
                delete(files(f,:));
            end
        end
        
        %if necessary, remove scans in the end
        if rmLast
            files = spm_select('FPList',runDir,'.*.nii');
            if size(files,1) > nScans
                for f = nScans+1:size(files,1)
                    delete(files(f,:));
                end
            end
        end
        
        %in sub09 run1, one volume less acquired, last one will be copied
        if subIDs(sub) == 9 && run == 1
            files = spm_select('FPList',runDir,'.*.nii');
            %copy last epi and rename file with consecutive image number
            %for brain images
            oldName = files(end,:);
            recNumber1 = (nScans+nDummy)/2-1;
            recNumber2 = nScans+nDummy-2;
            newName = regexprep(oldName, num2str(recNumber1), num2str(recNumber1+1), 'once');
            newName = regexprep(newName, num2str(recNumber2), num2str(recNumber2+2), 'once');
            copyfile(oldName,newName)
            %copy last epi and rename file with consecutive image number
            %for spinal images
            oldName = files(end-1,:);
            recNumber1 = (nScans+nDummy)/2-1;
            recNumber2 = nScans+nDummy-3;
            newName = regexprep(oldName, num2str(recNumber1), num2str(recNumber1+1), 'once');
            newName = regexprep(newName, num2str(recNumber2), num2str(recNumber2+2), 'once');
            copyfile(oldName,newName)
        end
        
        %move remaining files to subfolder
        files = spm_select('FPList',runDir,'.*.nii');
        for f=1:size(files,1)
            vol = str2double(files(f,end-10:end-7));
            if mod(vol,2)
                target = fullfile(runDir,folder{2});
            else
                target = fullfile(runDir,folder{1});
            end
            movefile(files(f,:),target);
        end
        
    end
    fprintf(1,'Sub%d: files moved to subdirectories\n',subID);
end



