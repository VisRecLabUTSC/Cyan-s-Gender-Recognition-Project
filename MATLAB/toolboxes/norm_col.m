function norm_col(fold)

namesfile= [fold,'/','filenames.txt'];
fold_crop=[fold,'/','crop_faces_a225b34L105iod60_res04'];%_res04
fold_col=[fold,'/','norm_col_res04_reduced'];%_res04
[status,message,messageid] = mkdir(fold_col);
coords= dlmread([fold,'/', 'coord.txt']);%only used to count files

mn_iod=60;%80;

a=2.25;%2.5
b=3.4;
L=mn_iod*10.5;%14; %30;11%14
ell_templ=design_ellipse(a, b, L);
ell_templ=single(ell_templ);
    %%%%%%%%%%%!!!resize 0.4 for modelling stims
     ell_templ=round(imresize(ell_templ, 0.4));
     
ell_templ=round((ell_templ+fliplr(ell_templ))/2);
ell_templ=round((ell_templ+flipud(ell_templ))/2);    
ell_templ=logical(ell_templ);
%imtool(ell_templ)


fid=fopen(namesfile, 'rt');

for k=1:size(coords,1)

    U{k}=fgetl(fid);
    im=imread([fold_crop, '/', U{k}(1:end-4),'.tif']);
    
        
%         im_sum=sum(im, 3);
%         im_bnr=im_sum<250*3;
%     %     imtool(im_bnr)
%         im_bnr=im_bnr(:);
%           ind=find(im_bnr);

    ind=find(ell_templ);

    im_lab=RGBToLab_conv(im);

    for compn=1:3
        im_compn=im_lab(:,:, compn);

        im_compn=im_compn(:);
        im_compn=im_compn(ind);

        mn_mat(k, compn)=mean(im_compn);
        std_mat(k, compn)=std(im_compn);
    end
end

fclose(fid)

mn_mat
std_mat

mean(mn_mat)
mean(std_mat)
%error
%old: params for 80 iod
% mns=[74.1369    9.0508   14.6381];%means for AR set or:   mean(mn_mat)
% stds=[9.1358    3.1228    4.1022];%mean(std_mat)
%params for 60 iod
mns=[74.1236    9.0272   14.6300];%means for AR set or:   mean(mn_mat)
stds=[9.0889    3.1079    4.0664];%mean(std_mat)



fid=fopen(namesfile);

for k=1:size(coords,1)
    
    U{k}=fgetl(fid);
    im=imread([fold_crop, '/', U{k}(1:end-4),'.tif']);


     ind=find(ell_templ);

    im_lab=RGBToLab(im);


    for compn=1:3
        im_compn=im_lab(:,:, compn);


        im_compn=im_compn-mn_mat(k, compn);
        im_compn=im_compn/(std_mat(k, compn)/stds(1,compn));

        im_compn=im_compn+mns(1, compn);
        im_lab(:,:,compn)=im_compn;
    end

    im_rgb=Lab2RGB(im_lab);
    for compn=1:3
        im_rgb(:,:, compn)=single(im_rgb(:,:, compn)).*single(ell_templ)+127*(1-single(ell_templ));
    end
   im_rgb=uint8(im_rgb);

    imwrite(im_rgb, [fold_col, '/', U{k}(1:end-4),'.tif'])
 end
end
    
    
    
