function [ratings_all,conditions_all] = extract_ratings(subIDs)

[path,vars]    = get_study_specs;
logDir         = path.logDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;

ratings_all = []; conditions_all = [];
for sub = 1:nSubs
    subDir    = fullfile(logDir,sprintf('sub%03d',subIDs(sub)),'pain');
    fprintf('sub%02d\n',subIDs(sub));
    % load(fullfile(subDir,sprintf('sub%03d_CPAR_CPM.mat',subIDs(sub))),'cparData');

    ratings = []; cond = [];
    for run = 1:nRuns

        logFile  = fullfile(subDir,sprintf('sub%03d_VAS_rating_block%d_phasicstim.mat',subIDs(sub),run));
        load(logFile,'VAS');
        %get run conditions
        load(fullfile(subDir,sprintf('sub%03d-run%d-onsets.mat',subIDs(sub),run+1)),'conditions');

        for block = 1:vars.nBlocks
            % if subIDs(sub) == 5 && run == 3 && block == 2
            % else
            % dataPhasic = cparData(run).data(block).Pressure02;
            % b = [0 find(spm_conv(dataPhasic,15)>4 & spm_conv(dataPhasic,15)<6)];
            % indStart = [];
            % for f = 1:size(b,2)-1
            %     if b(f+1)-b(f) ~= 1
            %         indStart = [indStart b(f+1)];
            %     end
            % end
            % maxPressure = dataPhasic(indStart(1:2:end)+40);
            % if any(diff(maxPressure)>2)
            %     disp('Pressure differences');
            % end
            % end
            for trial = 1:vars.nTrials
                if subIDs(sub) == 5 && run == 3 && block == 2 && trial > 6
                    vas(trial) = NaN;
                    res(trial) = NaN;
                else
                    vas(trial) = VAS(block,trial).phasicStim.finalRating;
                    res(trial) = VAS(block,trial).phasicStim.response;
                end
            end
            ind = find(res==0);
            for i = 1:length(ind)
                % vas(ind(i)) = mean(vas(res==1));
                P = polyfit(0:length(vas(res==1))-1,vas(res==1),1);
                vas(ind(i)) = P(2) + (ind(i)*P(1));

            end
            rating(:,block) = vas;
        end

        ratings_all(:,run,sub) = rating(:);
        if subIDs(sub) == 5 && run == 3
            conditions_all(:,run,sub) = [conditions' 1 1 1];
        else
            conditions_all(:,run,sub) = conditions';
        end

    end

end


