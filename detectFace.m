function [thresh,img_rgb]=detectFace(img);
%% Face Detection

faceDetector=vision.CascadeObjectDetector('FrontalFaceCART'); %Create a detector object
%img=imread('photo.jpg'); %Read input image
BB=step(faceDetector,img); % Detect faces

iimg=imcrop(img,BB(end,:));

  %face crop
figure(1);
imshow(iimg);
title('Detected face');

%% Skin Detection
%initialize matrix for thresholding
thresh_Y=zeros(size(iimg(:,:,1)));
thresh_Cb=zeros(size(iimg(:,:,1)));
thresh_Cr=zeros(size(iimg(:,:,1)));

% RGB to ycbcr
iimg_ycbcr=rgb2ycbcr(iimg);

%Cb comppnent for skin detetion
cb_comp=iimg_ycbcr(:,:,2);
thresh_Cb(cb_comp>=77 & cb_comp<=127)=1;

%Cr comppnent for skin detetion
cr_comp=iimg_ycbcr(:,:,3);
thresh_Cr(cr_comp>=133 & cr_comp<=173)=1;

%combining thresholoding matrices and hnging the datatype from double to unit8
thresh=cat(3, thresh_Y,thresh_Cb,thresh_Cr);
thresh=sum(thresh,3);
thresh(thresh<2)=0;
thresh(thresh>0)=1;
thresh=uint8(thresh);

%Final image
img_rgb=iimg.*thresh;

%display image
figure(2);
imshow(img_rgb);
title('Result after skin detection');
return
