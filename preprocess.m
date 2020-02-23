function [out]=preprocess(detrended_RGB,window_size,size_video,duration)

% Number of frames
f=window_size*uint8(size_video/duration);%Number of frames for preprocessing

if(size(detrended_RGB,2)==3)
 
% Separate out R ,G and B component    
detrended_R=detrended_RGB(:,1);
detrended_G=detrended_RGB(:,2);
detrended_B=detrended_RGB(:,3);

main_R=[];%preprocessed R component initialization
main_G=[];%preprocessed G component initialization
main_B=[];%preprocessed B component initialization

%final preprocessed components
for i=1:size(detrended_RGB,1)-f

    temp_R=detrended_R(i:i+f-1);
    temp_G=detrended_G(i:i+f-1);
    temp_B=detrended_B(i:i+f-1);

    main_R=[main_R;temp_R];%preprocessed R component
    main_G=[main_G;temp_G];%preprocessed G component
    main_B=[main_B;temp_B];%preprocessed B component

end

%Formulas used in the paper

X1=main_R-main_G;
X2=main_R+main_G-(2*main_B);

X1=X1-mean(X1);
X2=X2-mean(X2);
X2=(std(X1)/std(X2))*X2;
HB=X1-X2;
out=HB/(std(HB));
else
    % Separate out R ,G and B component    
detrended_R=detrended_RGB(:,1);
%detrended_G=detrended_RGB(:,:,2);
detrended_B=detrended_RGB(:,2);

main_R=[];%preprocessed R component initialization
%main_G=[];%preprocessed G component initialization
main_B=[];%preprocessed B component initialization

%final preprocessed components
for i=1:size(detrended_RGB,1)-f+1

    temp_R=detrended_R(i:i+f-1);
    %temp_G=detrended_G(i:i+f-1);
    temp_B=detrended_B(i:i+f-1);

    main_R=[main_R;temp_R];%preprocessed R component
    %main_G=[main_G;temp_G];%preprocessed G component
    main_B=[main_B;temp_B];%preprocessed B component

end% for loop ends


out=[main_R main_B];
end
return