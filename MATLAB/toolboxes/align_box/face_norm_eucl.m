function face_norm_eucl (fold)
%%normalizes image size by critical distance value
%%11.10.06


%%%select view
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = {'Front view', 'Profile'};
[sel,ok] = listdlg('PromptString','Select view:',...
                'SelectionMode','single',...
                'ListSize',[150 100],...
                'Name', 'View',...
                'ListString',str);
            
if ok==0
    error('No view selected!')
end

%%%input normalization parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sel==1
    def={'80', '2.5', '2'};
    cd_name=' interocular distance';
else def={'125', '1.6', '2'};
    cd_name=' eye-chin distance';
end

answ = inputdlg({['Critical distance -', cd_name,  ' (in pixels)'],...
                 'Horizontal image size (in critical distance units)',...
                 'Vertical image size (in critical distance units)'},...
                 'Normalized distance',...
                1, def);
            
            
crdm=str2num(char(answ(1)));
croph=round(crdm*str2num(char(answ(2))));
cropv=round(crdm*str2num(char(answ(3))));           
padding=160; %changed from 140
            
%%file/folder info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    fold=cd;
end

namesfile= 'filenames.txt';
coordfile= 'coord.txt';
coord= dlmread([fold, '/', coordfile]);

coordfile2='coord_norm.txt';
fold2=[fold,'/../norm_faces'];
[status,message,messageid] = mkdir(fold2);



%dfc=170;%%distance from the center


%%collect crit dist values from excel file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sel==1
    crd=coord(:,4)-coord(:,2);%%critical distance: iod
else %crd=round(sqrt((coord(:,6)-coord(:,2)).^2+(coord(:,5)-coord(:,1)).^2))
    crd=round(sqrt((coord(:,10)-coord(:,2)).^2+(coord(:,9)-coord(:,1)).^2));%%critical distance: eye-chin
    %crd=coord(:,9)-coord(:,1);%critical distance: eye-chin vert dist
end
% crdm=mean(crd);


%%normalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% length(crd)
fid=fopen([fold, '/', namesfile])
for i=1:length(crd)
    

    i=i
    U{i}=fgetl(fid);
    im=imread([fold, '/', U{i}]);
    
    %%%%%%rotate image; find new coords
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    centr=[size(im,1)/2 size(im,2)/2];
    h_coord=coord(i,1:2:end);
    v_coord=coord(i,2:2:end);
    h_coord=h_coord-centr(1,1);
    v_coord=v_coord-centr(1,2);

    offset=coord(i,1)-coord(i,3);
    d_hor=coord(i,4)-coord(i,2);
    alpha=atan(offset/d_hor);
    alpha_a=-(alpha*180)/pi;
    im=imrotate(im, alpha_a, 'bilinear');
    centr=[size(im,1)/2 size(im,2)/2];


    v_coord=v_coord*cos(alpha)-h_coord*sin(alpha);            
    h_coord=v_coord*sin(alpha)+h_coord*cos(alpha);

    h_coord=h_coord+centr(1,1);
    v_coord=v_coord+centr(1,2);

    coord(i,1:2:size(coord, 2))=h_coord;
    coord(i,2:2:size(coord, 2))=v_coord;

    coord(i,:)=round(coord(i,:));
%             verify_coord(coord(i,:), im)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    rt(i)=crdm/crd(i);
    im=imresize(im, rt(i), 'bilinear');
    coord(i,:)=round(coord(i,:)*rt(i));
    if sel==1
        cent(1)=coord(i,1)+round(abs((coord(i,3)-coord(i,1)))/2);
        cent(2)=coord(i,2)+round((coord(i,4)-coord(i,2))/2);
    else cent(1)=coord(i,1)+round(abs((coord(i,5)-coord(i,1)))/2);
        cent(2)=coord(i,2)+round((coord(i,6)-coord(i,2))/2);
    end
    
    im=padarray(im, [padding, padding], 256);%'replicate'
    cent=cent+padding;
    %im=im(cent(1)-dfc:cent(1)+dfc-1, cent(2)-dfc:cent(2)+dfc-1,:);
%     c=cent(1)
%     croph=croph
size(im)
    cent2 = cent(2)
    cropv
    cent(2)-cropv
    
    im = im(cent(1)-croph:cent(1)+croph-1, cent(2)-cropv:cent(2)+cropv-1,:);

    coord(i,:)=coord(i,:)+padding;
    coord(i,:)=coord(i,:)-repmat([cent(1)-croph-1 cent(2)-cropv-1], [1,5]);
    
    imwrite(im, strcat(fold2,'/',U{i}))
end
fclose(fid);


copyfile([fold, '/',namesfile], strcat(fold2,'/',namesfile));
dlmwrite(strcat(fold2,'/',coordfile2), coord);