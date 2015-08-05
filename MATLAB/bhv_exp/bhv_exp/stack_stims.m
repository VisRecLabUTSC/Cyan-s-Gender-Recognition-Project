
function stack_stims

picdir='stims';
pics=dir(fullfile(picdir,'*.tif'));  
    
        
nfl=size(pics,1)
for fl=1:nfl
    U{fl}=pics(fl).name;

    im=imread(fullfile(picdir, U{fl}));
    %imtool(im)
    if fl==1
        [sz1 sz2 sz3]=size(im)
        im_mat=uint8(zeros(sz1, sz2, sz3));
    end
    im_mat(:,:,:, fl)=im;

end

U=U
save([picdir, '/stim_mat.mat'], 'im_mat')
