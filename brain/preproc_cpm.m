function preproc_cpm

addpath('..\global');
addpath('..\utils');


subIDs = [1:49]; %1:49

exclude = [3 7 14 19 28 35 36 41 ];

subIDs = subIDs(~ismember(subIDs,exclude));

sort     = 0;
copy     = 1;
nicon    = 0;
rigid    = 0;
realign1 = 0;
segment  = 0;
dartel   = 0;
coreg    = 0;
skull    = 0;
realign2 = 0;
episeg   = 0;
warp     = 0;

if sort
    rmDummy = 1;
    rmLast = 1;
    sort_images(subIDs,rmDummy,rmLast);
end

if copy
    % 1: brain; 2: spinal; []: all
    folderID = 2; 
    copy_raw_data(subIDs,folderID);
end

if nicon 
    del3D = 1;
    convert_files(subIDs,del3D);
end

if rigid == 1
    change_origin(subIDs);
end

if realign1 == 1
    mask = 0;
    realign_images(subIDs,mask);
end

if segment == 1
    imgID = 2; % 1:mean Epi; 2: T1
    segment_image(subIDs,imgID);
end

if dartel == 1
    imgID = 2; % 1:mean Epi; 2: T1
    dartel_image(subIDs,imgID);  
    get_backwards_trans(subIDs);
end

if coreg == 1
     coreg_nonlin(subIDs);
     create_trans(subIDs);
end

if skull == 1
    imgID = 1; % 1:mean Epi; 2: T1
    create_skullstrip(subIDs,imgID);
    % create_mask(subIDs);
end

if realign2 == 1
    mask = 1; 
    realign_images(subIDs,mask);
end

if episeg == 1
    imgID = 1; % 1:mean Epi; 2: T1
    segment_image(subIDs,imgID);
end

if warp == 1
    %1: meanEpi; 2: T1; 3: all Epis; 4: epimask; todo:con images
    imgID = [4]; 
    warp_images(subIDs,imgID); 
    % create_means(subIDs);
    %warp_images2(subIDs); 
end

