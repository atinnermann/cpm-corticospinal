function sbp_convert_physio_smr(subIDs)

[path,vars]     = get_study_specs;
nSubs           = length(subIDs);

physioDir       = path.physioDir;
rawDir          = fullfile(physioDir,'raw');

% Add CED
cedPath = fileparts(which('CEDS64LoadLib'));
if isempty(cedPath)
    error('Cannot find CED toolbox in your path. This toolbox is required for the next steps. For more information see the readme.txt');
end
CEDS64LoadLib(cedPath);
% loadlibrary ceds64int

for sub = 1:nSubs
    subDir = fullfile(physioDir,sprintf('sub%02d',subIDs(sub)),'physio');
    fprintf('\n\nRunning physio preprocessing for sub%02d ...',subIDs(sub))
    
    if ~exist(subDir,'dir')
        mkdir(subDir);
    end

    % Session loop
    for ses = 1:vars.nSess
        % SMR raw dir and filename for each session
        smrFile = fullfile(rawDir,sprintf('sub%03d.smr',subIDs(sub)));

        % Skip if we do not have physio smr file
        if isempty(regexp(smrFile,'.*\.smr','MATCH'))
            fprintf('\nNo SMR file for sub%02d ses%02d. Skipping ...\n',subIDs(sub),ses);
            continue;
        end

        % Make filenames for raw and preprocessed mat files
        matFile   = fullfile(subDir,sprintf('sub%02d_physio.mat',subIDs(sub)));

        % % Mat Raw and Preprocessed dirs for each session
        % mkdir(fullfile(matDir,sprintf('sub-%02d',subIDs(sub)),sprintf('ses-%02d',ses)))

        fhand = CEDS64Open(smrFile,1);
        [ NChannels ] = CEDS64MaxChan( fhand );
        [ dTBaseOut ] = CEDS64TimeBase( fhand ); % this is the time base, that is, the highest resolution time over all channels, on which i64Div is applied in each to get actual resolution

        fprintf('\n\nConversion SMR to MAT: file %s\n',smrFile);

        m = matfile(matFile,'writable',true); % instantiate file
        for iChan = 1:NChannels
            [ iType ] = CEDS64ChanType( fhand, iChan ); % find out if the channel is a wave channel

            if ~iType
                continue;
            end

            fprintf('\nchannel %d sub%02d',iChan,subIDs(sub));

            tempStruct = struct;

            [ ~, sTitleOut ] = CEDS64ChanTitle( fhand, iChan );
            [ ~, sCommentOut ] = CEDS64ChanComment( fhand, iChan);

            i64MaxTime = CEDS64ChanMaxTime( fhand, iChan );
            if i64MaxTime==-1
                if iChan ~= 31                                                  % Chan 31 always gives a warning for some reason, but is being disregarded as it is not used with the settings used by our psychophysics settings.
                    warning('Channel %d is empty, skipping...',iChan)
                end
                continue;
            end

            [ i64Div ] = CEDS64ChanDiv( fhand, iChan );

            tempStruct.title = sTitleOut;
            tempStruct.comment = sCommentOut;

            fprintf('(%s)... ',sTitleOut);

            [ i64MaxTime ] = CEDS64ChanMaxTime( fhand, iChan );

            if iType==1 % data channel

                [ ~, dOffsetOut ]   = CEDS64ChanOffset( fhand, iChan );
                [ ~, sUnitsOut ]    = CEDS64ChanUnits( fhand, iChan );
                [ ~, fVals, i64Time ] = CEDS64ReadWaveF( fhand, iChan, ceil(i64MaxTime/i64Div), 0 );
                fVals = double(fVals);

                tempStruct.interval = dTBaseOut*i64Div; % ms resolution
                tempStruct.scale = 0; % unclear
                tempStruct.offset = dOffsetOut;
                tempStruct.units = sUnitsOut;
                tempStruct.start = i64Time;
                tempStruct.length = numel(fVals);
                tempStruct.values = fVals;

            elseif iType==3

                [ ~, i64Times ] = CEDS64ReadEvents( fhand, iChan, ceil(i64MaxTime/i64Div), 0);
                if isempty(i64Times)
                    if iChan ~= 31
                        warning('Channel %d of sub%02d is empty, skipping...',iChan,subIDs(sub))
                    end
                    continue;
                end
                [ dSeconds ] = CEDS64TicksToSecs( fhand, i64Times );

                tempStruct.resolution = dTBaseOut;
                tempStruct.length = numel(dSeconds);
                tempStruct.times = dSeconds;

            end

            m.(sprintf('sub%02d_Ch%d',subIDs(sub),iChan)) = tempStruct;

        end
        CEDS64Close(fhand); 
    end
end
unloadlibrary ceds64int;
end
