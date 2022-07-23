close all;
clear all;
clc;
%% DICOM read
addpath('C:\Users\user\Downloads\20220428_monkey_3D_T1w\3D_T1w\DICOM\DICOM');
folder = 'C:\Users\user\Downloads\20220428_monkey_3D_T1w\3D_T1w\DICOM\DICOM\';
fileList = dir(fullfile(folder, 'IM*'));

fileList = {fileList.name};
for i = 1:length(fileList)
dcminfo{i} = dicominfo(fileList{i});
dcm(:,:,i) = double(dicomread(fileList{i}));
end
figure; imagesc(dcm(:,:,55));

%% Position sorting
for i = 1:length(fileList)
L(i) = dcminfo{i}.ImagePositionPatient(1);
end

[out,idx]  = sort(L);
dcm_new = dcm(:,:,idx);

figure; imagesc(dcm_new(:,:,55));

%% Masking - thresholding
S = dcm_new;
for i = 1:size(S,1)
    for j = 1:size(S,2)
        for k = 1:size(S,3)
            if S(i,j,k) <=20
                M2(i,j,k) = 0;
            elseif S(i,j,k) >= 0
                M2(i,j,k) = 1;
            end
        end
    end
end
figure; imagesc(M2(:,:,55));

%% Median Filtering
for i = 1:size(S,1)
Kmedian(i,:,:) = imfill(medfilt2(squeeze(M2(i,:,:))));
end
for j = 1:size(S,2)
Kmedian(:,j,:) = imfill(medfilt2(squeeze(M2(:,j,:))));
end
for k = 1:size(S,3)
Kmedian(:,:,k) = imfill(medfilt2(squeeze(M2(:,:,k))));
end
imshowpair(M2(:,:,55),Kmedian(:,:,55),'montage')

%% Removal of small outlier volumes
for i = 1:size(S,1)
BW2(i,:,:) = bwareaopen(Kmedian(i,:,:), 5000);
end
for j = 1:size(S,2)
BW2(:,j,:) = bwareaopen(Kmedian(:,j,:), 5000);
end
for k = 1:size(S,3)
BW2(:,:,k) = bwareaopen(Kmedian(:,:,k), 5000);
end

imshowpair(Kmedian(:,:,55),BW2(:,:,55),'montage')

% se = offsetstrel('ball',10,10);
% erodedI = imerode(double(BW2),se);
% imshowpair(BW2(:,:,55),erodedI(:,:,55),'montage')

%% Dilation of volume
se = offsetstrel('ball',20,20);
dilatedI = imdilate(double(BW2),se);
imshowpair(BW2(:,:,55),dilatedI(:,:,55),'montage')
dilatedI(dilatedI<19.995)=0;
imshowpair(BW2(:,:,55),dilatedI(:,:,55),'montage')

%% Re-Filtering
for i = 1:size(S,1)
Kmedian2(i,:,:) = imfill(medfilt2(squeeze(dilatedI(i,:,:))));
end
for j = 1:size(S,2)
Kmedian2(:,j,:) = imfill(medfilt2(squeeze(dilatedI(:,j,:))));
end
for k = 1:size(S,3)
Kmedian2(:,:,k) = imfill(medfilt2(squeeze(dilatedI(:,:,k))));
end

imshowpair(BW2(:,:,55),Kmedian2(:,:,55),'montage')

volumeViewer
% dcm_new_2 = dcm_new.*Kmedian2;
% imshowpair(dcm_new(:,:,55),dcm_new_2(:,:,55),'montage')



%% Resizing and reshaping
A = double(Kmedian2);
figure(); imagesc(squeeze(A(:,:,30))); colormap('gray');
%%

%%
Iblur = imgaussfilt(A,2);
Iblur = imfill(double(Iblur),'holes') ;
%figure(); imagesc(squeeze(Iblur(:,:,30))); colormap('gray');
windowSize = 5;
kernel = ones(windowSize) / windowSize ^ 2;
%figure()


blurryImage = zeros(320,320,111);
for F1 = 1: 111

    blurryImage(:, :, F1) = conv2((Iblur(:,:,F1)), kernel, 'same');
    
end

% blurryImage = conv2((mask_22(:,:,img_num)), kernel, 'same');
figure(); imagesc(squeeze(blurryImage(:,:,30))); colormap('gray');

se = strel('line',11,90);
ax = strel('line',11,0);

BW1 = imdilate(blurryImage,se);
BW1 = imfill(double(BW1),'holes') ;
%figure(); imagesc(squeeze(BW1(:,:,30))); colormap('gray');
erodedBW1 = imerode(BW1,se);
erodedBW1 = imfill(double(erodedBW1),'holes') ;
%figure(); imagesc(squeeze(erodedBW1(:,:,30))); colormap('gray');
BW11 = imdilate(erodedBW1,ax);
BW11 = imfill(double(BW11),'holes') ;
%figure(); imagesc(squeeze(BW11(:,:,img_num))); colormap('gray');
erodedBW11 = imerode(BW11,ax);
erodedBW11 = imfill(double(erodedBW11),'holes') ;
%figure(); imagesc(squeeze(erodedBW11(:,:,img_num))); colormap('gray');

BW111 = imdilate(erodedBW11,se);
BW111 = imfill(double(BW111),'holes') ;
%figure(); imagesc(squeeze(BW111(:,:,img_num))); colormap('gray');
erodedBW111 = imerode(BW111,se);
erodedBW111 = imfill(double(erodedBW111),'holes') ;
%figure(); imagesc(squeeze(erodedBW111(:,:,img_num))); colormap('gray');

BW1111 = imdilate(erodedBW111,ax);
BW1111 = imfill(double(BW1111),'holes') ;
%figure(); imagesc(squeeze(BW1111(:,:,img_num))); colormap('gray');
erodedBW1111 = imerode(BW1111,ax);
erodedBW1111 = imfill(double(erodedBW1111),'holes') ;
%figure(); imagesc(squeeze(erodedBW1111(:,:,img_num))); colormap('gray');

%% imerode imdilate
erodedBW2 = imerode(erodedBW1111,se);
erodedBW2 = imfill(double(erodedBW2),'holes') ;
%figure(); imagesc(squeeze(erodedBW2(:,:,img_num))); colormap('gray');
BW2 = imdilate(erodedBW2,se);
BW2 = imfill(double(BW2),'holes') ;

%figure(); imagesc(squeeze(BW2(:,:,img_num))); colormap('gray');
erodedBW22 = imerode(BW2,ax);
erodedBW22 = imfill(double(erodedBW22),'holes') ;
%figure(); imagesc(squeeze(erodedBW22(:,:,img_num))); colormap('gray');
BW22 = imdilate(erodedBW22,ax);
BW22 = imfill(double(BW22),'holes') ;
%figure(); imagesc(squeeze(BW22(:,:,img_num))); colormap('gray');

erodedBW222 = imerode(BW22,se);
erodedBW222 = imfill(double(erodedBW222),'holes') ;
%figure(); imagesc(squeeze(erodedBW222(:,:,img_num))); colormap('gray');
BW222 = imdilate(erodedBW222,se);
BW222 = imfill(double(BW222),'holes') ;
%figure(); imagesc(squeeze(BW222(:,:,img_num))); colormap('gray');

erodedBW2222 = imerode(BW222,ax);
erodedBW2222 = imfill(double(erodedBW2222),'holes') ;
%figure(); imagesc(squeeze(erodedBW2222(:,:,img_num))); colormap('gray');
BW2222 = imdilate(erodedBW2222,ax);
BW2222 = imfill(double(BW2222),'holes') ;
%figure(); imagesc(squeeze(BW2222(:,:,img_num))); colormap('gray');

%%
erodedBW3 = imerode(BW2222,se);
erodedBW3 = imfill(double(erodedBW3),'holes') ;
%figure(); imagesc(squeeze(erodedBW3(:,:,img_num))); colormap('gray');
BW3 = imdilate(erodedBW3,se);
BW3 = imfill(double(BW3),'holes') ;
%figure(); imagesc(squeeze(BW3(:,:,30))); colormap('gray');
mask = BW3 > 20;
figure(); imagesc(squeeze(mask(:,:,30))); colormap('gray');

%%
% figure(); imagesc(squeeze(BW3(:,:,40))); colormap('gray');


data = smooth3(mask,'box',9);
data = smooth3(data,'box',9);
data = smooth3(data,'box',9);
data = smooth3(data,'box',9); 
figure(); imagesc(squeeze(data(:,:,40))); colormap('gray');
data = double(data>0.3);
figure(); imagesc(squeeze(data(:,:,40))); colormap('gray');

figure();
patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','yellow','EdgeColor','none');
isonormals(data,p1);
view(3); 
axis vis3d tight
camlight left
lighting gouraud

%%

[m1,n1,p1]= size(data) ;
x0 = 0.46875 ; y0 = 0.46875 ; z0 = 0.9 ;
x1 = x0+(m1-1)*x0 ;
y1 = y0+(n1-1)*y0 ;
z1 = z0+(p1-1)*z0 ;
x = linspace(x0,x1,m1) ;
y = linspace(y0,y1,n1) ;
z = linspace(z0,z1,p1) ;
[X1,Y1,Z1] = ndgrid(x,y,z) ;
xi = linspace(x0,x1,250) ;
yi = linspace(y0,y1,250) ;
zi = linspace(z0,z1,250) ;
[Xi,Yi,Zi] = ndgrid(xi,yi,zi) ;
Ai = interpn(X1,Y1,Z1,data,Xi,Yi,Zi) ;

figure();imshowpair(data(:,:,55),Ai(:,:,125),'montage')

%% MAT to STL
gridINPUT = Ai;
gridX = xi;
gridY = yi;
gridZ = zi;
%Convert the binary data to an STL mesh:
[faces,vertices] = CONVERT_voxels_to_stl('monkey_4.stl',gridINPUT,gridX,gridY,gridZ,'ascii');

%%
Iblur = imgaussfilt(A,2);
Iblur = imfill(double(Iblur),'holes') ;
%figure(); imagesc(squeeze(Iblur(:,:,30))); colormap('gray');
windowSize = 5;
kernel = ones(windowSize) / windowSize ^ 2;
%figure()


blurryImage = zeros(320,320,111);
for F1 = 1: 111

    blurryImage(:, :, F1) = conv2((Iblur(:,:,F1)), kernel, 'same');
    
end

% blurryImage = conv2((mask_22(:,:,img_num)), kernel, 'same');
figure(); imagesc(squeeze(blurryImage(:,:,30))); colormap('gray');

se = strel('line',11,90);
ax = strel('line',11,0);

BW1 = imdilate(blurryImage,se);
BW1 = imfill(double(BW1),'holes') ;
%figure(); imagesc(squeeze(BW1(:,:,30))); colormap('gray');
erodedBW1 = imerode(BW1,se);
erodedBW1 = imfill(double(erodedBW1),'holes') ;
%figure(); imagesc(squeeze(erodedBW1(:,:,30))); colormap('gray');
BW11 = imdilate(erodedBW1,ax);
BW11 = imfill(double(BW11),'holes') ;
%figure(); imagesc(squeeze(BW11(:,:,img_num))); colormap('gray');
erodedBW11 = imerode(BW11,ax);
erodedBW11 = imfill(double(erodedBW11),'holes') ;
%figure(); imagesc(squeeze(erodedBW11(:,:,img_num))); colormap('gray');

BW111 = imdilate(erodedBW11,se);
BW111 = imfill(double(BW111),'holes') ;
%figure(); imagesc(squeeze(BW111(:,:,img_num))); colormap('gray');
erodedBW111 = imerode(BW111,se);
erodedBW111 = imfill(double(erodedBW111),'holes') ;
%figure(); imagesc(squeeze(erodedBW111(:,:,img_num))); colormap('gray');

BW1111 = imdilate(erodedBW111,ax);
BW1111 = imfill(double(BW1111),'holes') ;
%figure(); imagesc(squeeze(BW1111(:,:,img_num))); colormap('gray');
erodedBW1111 = imerode(BW1111,ax);
erodedBW1111 = imfill(double(erodedBW1111),'holes') ;
%figure(); imagesc(squeeze(erodedBW1111(:,:,img_num))); colormap('gray');

%% imerode imdilate
erodedBW2 = imerode(erodedBW1111,se);
erodedBW2 = imfill(double(erodedBW2),'holes') ;
%figure(); imagesc(squeeze(erodedBW2(:,:,img_num))); colormap('gray');
BW2 = imdilate(erodedBW2,se);
BW2 = imfill(double(BW2),'holes') ;

%figure(); imagesc(squeeze(BW2(:,:,img_num))); colormap('gray');
erodedBW22 = imerode(BW2,ax);
erodedBW22 = imfill(double(erodedBW22),'holes') ;
%figure(); imagesc(squeeze(erodedBW22(:,:,img_num))); colormap('gray');
BW22 = imdilate(erodedBW22,ax);
BW22 = imfill(double(BW22),'holes') ;
%figure(); imagesc(squeeze(BW22(:,:,img_num))); colormap('gray');

erodedBW222 = imerode(BW22,se);
erodedBW222 = imfill(double(erodedBW222),'holes') ;
%figure(); imagesc(squeeze(erodedBW222(:,:,img_num))); colormap('gray');
BW222 = imdilate(erodedBW222,se);
BW222 = imfill(double(BW222),'holes') ;
%figure(); imagesc(squeeze(BW222(:,:,img_num))); colormap('gray');

erodedBW2222 = imerode(BW222,ax);
erodedBW2222 = imfill(double(erodedBW2222),'holes') ;
%figure(); imagesc(squeeze(erodedBW2222(:,:,img_num))); colormap('gray');
BW2222 = imdilate(erodedBW2222,ax);
BW2222 = imfill(double(BW2222),'holes') ;
%figure(); imagesc(squeeze(BW2222(:,:,img_num))); colormap('gray');

%%
erodedBW3 = imerode(BW2222,se);
erodedBW3 = imfill(double(erodedBW3),'holes') ;
%figure(); imagesc(squeeze(erodedBW3(:,:,img_num))); colormap('gray');
BW3 = imdilate(erodedBW3,se);
BW3 = imfill(double(BW3),'holes') ;
%figure(); imagesc(squeeze(BW3(:,:,30))); colormap('gray');



%%
% figure(); imagesc(squeeze(BW3(:,:,40))); colormap('gray');


data = smooth3(blurryImage,'box',9);
data = smooth3(data,'box',9);
data = smooth3(data,'box',9);
data = smooth3(data,'box',9); 
figure();

patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','yellow','EdgeColor','none');
isonormals(data,p1);

view(3); 
axis vis3d tight
camlight left
lighting gouraud

A = data;
[m1,n1,p1]= size(A) ;
x0 = 0.46875 ; y0 = 0.46875 ; z0 = 0.9 ;
x1 = x0+(m1-1)*x0 ;
y1 = y0+(n1-1)*y0 ;
z1 = z0+(p1-1)*z0 ;
x = linspace(x0,x1,m1) ;
y = linspace(y0,y1,n1) ;
z = linspace(z0,z1,p1) ;
[X1,Y1,Z1] = ndgrid(x,y,z) ;
xi = linspace(x0,x1,250) ;
yi = linspace(y0,y1,250) ;
zi = linspace(z0,z1,250) ;
[Xi,Yi,Zi] = ndgrid(xi,yi,zi) ;
Ai = interpn(X1,Y1,Z1,A,Xi,Yi,Zi) ;

figure();imshowpair(A(:,:,55),Ai(:,:,125),'montage')

%% MAT to STL
gridINPUT = Ai;
gridX = xi;
gridY = yi;
gridZ = zi;
%Convert the binary data to an STL mesh:
[faces,vertices] = CONVERT_voxels_to_stl('monkey_2.stl',gridINPUT,gridX,gridY,gridZ,'ascii');
