function [img_rgb_mean] = spatialAverage(thresh,img_rgb);
%% Spatial Averaging and Translating image to signal(R,G,B)
[ind_row,ind_col]=find(thresh==1);
ind_img=[ind_row,ind_col];
sig_final=zeros(size(ind_img,1),3);
for i=1:size(ind_img)
    sig_temp=img_rgb(ind_img(i,1),ind_img(i,2),:);
    sig_temp=reshape(sig_temp,1,3);
    sig_final(i,:)=sig_final(i,:)+double(sig_temp);     
end

%Final Resultant values of image
img_rgb_mean=mean(sig_final);
return