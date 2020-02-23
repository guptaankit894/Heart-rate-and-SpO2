clc
clear;
close all;
tic
%% Reading a video
Vid=VideoReader('WIN_20200218_16_02_44_Pro.mp4');
%% Getting the first frame for skin detection
first_frame=read(Vid,1);
[thresh,img_rgb]=detectFace(first_frame);
%% Spatial Filtering
size_video=Vid.NumberOfFrames;
final_sig=[];
for i= 1:size_video
    frame=read(Vid,i);
    [img_rgb_mean] = spatialAverage(thresh,frame);
    final_sig=[final_sig;img_rgb_mean];
    
end
%% Detrending

%detrending R channel
z1=final_sig(:,1);
detrended_R=detrending(z1);

%detrending G channel
z2=final_sig(:,2);
detrended_G=detrending(z2);

%detrending B channel
z3=final_sig(:,3);
detrended_B=detrending(z3);
detrended_RGB=[detrended_R,detrended_G,detrended_B];
%% Heart Beat Estimation
window_size=30;
frame_rate=uint8(Vid.FrameRate);
[HB]=preprocess(detrended_RGB,window_size,size_video,Vid.Duration);
%% Dual Tree Complex Wavelet Transform
First_level=[
0	0	0.01122679	0;
-0.08838834	-0.01122679	0.01122679	0;
0.08838834	0.01122679	-0.08838834	-0.08838834;
0.69587998	0.08838834	0.08838834	-0.08838834;
0.69587998	0.08838834	0.69587998	0.69587998;
0.08838834	-0.69587998	0.69587998	-0.69587998;
-0.08838834	0.69587998	0.08838834	0.08838834;
0.01122679	-0.08838834	-0.08838834	0.08838834;
0.01122679	-0.08838834	0	0.01122679;
0	0	0	-0.01122679];

Rem_level=[
0.03516384	0	0	-0.03516384;
0	0	0	0;
-0.08832942	-0.11430184	-0.11430184	0.08832942;
0.23389032	0	0	0.23389032;
0.76027237	0.58751830	0.58751830	-0.76027237;
0.58751830	-0.76027237	0.76027237	0.58751830;
0	0.23389032	0.23389032	0;
-0.11430184	0.08832942	-0.08832942	-0.11430184;
0	0	0	0;
0	-0.03516384	0.03516384	0;
];
% first level analytics 'af'  and synthesis filters 'sf'
faf{1}=First_level(:,[1,2]);
fsf{1} = faf{1}(end:-1:1, :);

faf{2}=First_level(:,[3,4]);
fsf{2} = faf{2}(end:-1:1, :);

% 2nd and 3rd level analytics 'af'  and synthesis filters 'sf'
af{1}=Rem_level(:,[1,2]);
sf{1} = af{1}(end:-1:1, :);

af{2}=Rem_level(:,[3,4]);
sf{2} = af{2}(end:-1:1, :);

w = dualtree(HB, 3, faf, af);% 1D-DT-CWT

% Components from wavelet coefficients
D1=[w{1}{1} w{1}{2}];
D2=[w{2}{1} w{2}{2}];
D3=[w{3}{1} w{3}{2}];
A1=[w{4}{1} w{4}{2}];

%% Soft Thresholding and Threshold calculation
%complex form of coefficients
D1_new=complex(D1(:,1),D1(:,2));
D2_new=complex(D2(:,1),D2(:,2));
D3_new=complex(D3(:,1),D3(:,2));
A1_new=complex(A1(:,1),A1(:,2));

%Threshold Calculation
%D1
T_D1_new=1.4*(mean(D1_new)-0.1*std(D1_new));
T_D1_new=abs(T_D1_new);

%D2 Threshold
T_D2_new=1.4*(mean(D2_new)-0.1*std(D2_new));
T_D2_new=abs(T_D2_new);

%D3 Threshold
T_D3_new=1.4*(mean(D3_new)-0.1*std(D3_new));
T_D3_new=abs(T_D3_new);

%A1Threshold
T_A1_new=1.4*(mean(A1_new)-0.1*std(A1_new));
T_A1_new=abs(T_A1_new);


% D1 component
D1(abs(D1)<=T_D1_new)=0;
for i=1:size(D1,1)
    if(abs(D1(i))>0)
        D1(i)=abs(D1(i))-T_D1_new;
    end
end

%D2 component
D2(abs(D2)<=T_D2_new)=0;
for i=1:size(D2,1)
    if(abs(D2(i))>0)
        D2(i)=abs(D2(i))-T_D2_new;
    end
end

%D3 component
D3(abs(D3)<=T_D3_new)=0;
for i=1:size(D3,1)
    if(abs(D3(i))>0)
        D3(i)=abs(D3(i))-T_D3_new;
    end
end

%A1 component
% A1(abs(A1)<=T_A1_new)=0;
% for i=1:size(A1,1)
%     if(abs(A1(i))>0)
%         A1(i)=abs(A1(i))-T_A1_new;
%     end
% end

%% Signal Reconstruction using Inverse Dual Tree Complex Wavelet Transform
%w{1}{1}=D1(:,1);
w{1}{1}(:,:)=0;
w{1}{2}=D1(:,2);

%w{2}{1}=D2(:,1);
w{1}{1}(:,:)=0;
w{2}{2}=D2(:,2);

w{3}{1}=D3(:,1); 
w{3}{2}=D3(:,2);

HB_new=idualtree(w, 3, fsf, sf); 

HB_ffted=fft(HB_new); % Fourier transform of the filtered signal.

% filter design using specification in the paper (64 point hamming window and frequency range-(0.7 to 4 Hz))
bp = designfilt('bandpassfir', 'FilterOrder', 40, 'CutoffFrequency1', 0.7, 'CutoffFrequency2', 4, 'SampleRate', 30, 'Window', 'hamming');

HB_filtered=filter(bp,detrend(abs(HB_new))); % applying the design filter

HB_peak=findpeaks(abs(HB_filtered)); % Finding peaks

max_peak=max(HB_peak);  % finding max peak

Heart_Rate=round(max_peak*60) % Heart Rate calculation
%% Spo2 Estimation
A=101.6;
B=5.834;
SpO_pre=[final_sig(:,1) final_sig(:,3)];
[SpO2]=preprocess(SpO_pre,10,size_video,Vid.duration);%preprocessing

%DC  and AC components of R channel after preprocessing
DC_R_comp=mean(SpO2(:,1));
AC_R_comp=std(SpO2(:,1));

I_r=AC_R_comp/DC_R_comp;% I ratio for R component

%DC and AC components of R channel after preprocessing
DC_G_comp=mean(SpO2(:,2));
AC_G_comp=std(SpO2(:,2));

I_g=AC_G_comp/DC_G_comp;% I ratio for G component

% SpO2 Estimation Formula
SpO2_value=round(A-B*((I_r*650)/(I_g*950)))

toc