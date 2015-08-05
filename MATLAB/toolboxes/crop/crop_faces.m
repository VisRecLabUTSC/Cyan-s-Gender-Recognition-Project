function crop_faces(fold)

namesfile= [fold,'/','filenames.txt'];
fold_norm=[fold,'/','norm_faces'];%_res04
fold_crop=[fold,'/','crop_faces_a225b34L105iod60_res04_reduced'];%a225b34L105iod60 %a225b34L14_res03
[status,message,messageid] = mkdir(fold_crop);
%[coords, U]= xlsread([fold_norm,'/', 'coord_norm.xls']);
coords= dlmread([fold_norm,'/', 'coord_norm.txt']);%dlmread([fold,'/', 'coord_norm.txt']);%

% centers_hor=round((mean(coords(:,[1 3]), 2) + coords(:,5))/2); %midway eye line and nose tip
% centers_hor= coords(:,5); %%nose tip
centers_hor=round(mean(coords(:,[1 3]), 2)*1/4 + coords(:,5)*3/4);
centers_vert=round(mean(coords(:,[2 4]), 2))+1;%%some correction for pose +k
iod=round(sqrt((coords(:,1)-coords(:,3)).^2+(coords(:,2)-coords(:,4)).^2));
mn_iod=60;%80%round(mean(iod))%80%32%!!!keep orig 80 if resizing (since L is based on it)


a=2.25;
b=3.4;
L=mn_iod*10.5;%14; %5.6
ell_templ=design_ellipse(a, b, L);
ell_templ=single(ell_templ);

%sum(sum(ell_templ))
%imtool(ell_templ)
%size(ell_templ)
%error
 % imwrite(ell_templ, [fold_crop, '/ell_templ.tif'])

halfh=round(size(ell_templ,2)/2);
halfv=round(size(ell_templ,1)/2);
h_coords=centers_hor-halfv: centers_hor-halfv+size(ell_templ,1)-1;
v_coords=centers_vert-halfh: centers_vert-halfh+size(ell_templ,2)-1;


    %%%%%%%%%%%!!!resize 0.4 for modelling stims
     ell_templ=round(imresize(ell_templ, 0.4));
     
     
ell_templ=round((ell_templ+fliplr(ell_templ))/2);
ell_templ=round((ell_templ+flipud(ell_templ))/2);


fid=fopen(namesfile);

for i=1:size(coords,1)
    
    U{i}=fgetl(fid);
    im=imread([fold_norm, '/', U{i}(1:end-4),'.tif']);%fold_norm
    
    
    %imtool(im)
    im=im(h_coords,v_coords, :);

%   double-precision for 2013 MATLAB    
    im=double(im);
    %imtool(im/255)
    
    im=imresize(im, 0.4, 'bilinear');%0.36 %0.26
    
    sz_im=size(im)
    sz_templ=size(ell_templ)
    im=im.*double(repmat(ell_templ, [1 1 3]));
    

    %im=im+(1-repmat(ell_templ, [1 1 3]))*127;%color bkg w/ sth other than black
    im=im/255;  
    %imtool(im)

    
    %class(im)
    
    %im=imresize(im, 0.4, 'bilinear');%0.36 %0.26
%     size(im)
%imtool(ell_templ)
%       imtool(im)
%      error
    % im=im2uint16(im);
    imwrite(im, [fold_crop, '/',  U{i}(1:end-4),'.tif'])
%   MATLAB version compatibility fix: write as jpg instead
%   swap line 63 for line 66 to revert
%   imwrite(im, [fold_crop, '/',  U{i}(1:end-4),'.jpg'])
end

