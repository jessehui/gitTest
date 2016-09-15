% All you need is just what Prof. Schonfeld explained in class. 
% In brief The steps would be : taking a very short video, 
% load it to MATLAB, if there is a total of n frames in video 
% you need to extract Y I Q components for each frame, 
% modulate Y in low frequency and Q and I in high frequency 
% with QAM modulation technique. And at the receiver side 
% seperate Y, I and Q using low pass filter. And convert it to RGB. 
%Do this process for all the frames in video and then you
% will have the transmitted video at receiver side. Good luck.




% transmitter side

%1. load the video
filename = 'My_video.mp4';
obj_video = VideoReader(filename);
numFrames = obj_video.NumberOfFrames;
numFrames_test = numFrames - 193;
height = obj_video.Height;
width = obj_video.Width;
frameRate = ceil(obj_video.FrameRate);         % number of frames per second\
Fs = double(height*width*frameRate);        %sampling frequency

%2. convert the frame of the video from RGB space to YIQ space
frame = uint8(zeros(obj_video.Height, obj_video.Width, 3, numFrames));  %get  all indexes for each pixel of each frame
frame_YIQ =double(frame);      %duplicate another space for frame in YIQ space

for k = 1: numFrames_test    % -190 just for test efficiency
	frame(:,:,:,k) = read(obj_video,k);	%read the frame of each index
    imshow(frame(:,:,:,k));
end

for k = 1: numFrames_test
    frame_YIQ(:,:,:,k) = rgb2ntsc(frame(:,:,:,k));       %converts the m-by-3 RGB values in rgbmap to NTSC color space(YIQ)
end

%3. get Y, I , Q components
Y = zeros(obj_video.Height, obj_video.Width, numFrames_test);
I = Y;
Q = Y;

for k = 1: numFrames_test
    Y(:,:,k) = frame_YIQ(:,:,1,k);
    I(:,:,k) = frame_YIQ(:,:,2,k);
    Q(:,:,k) = frame_YIQ(:,:,3,k);
end

N = height*width*numFrames_test;
y = zeros(1, N);
m=1;
for k = 1: numFrames_test
    for i = 1: height
        for j = 1: width
            y(m) = Y(i,j,k);   %(height, width, frame)
            m = m+1;
        end
    end
end

Y_FFT = fft(y);
%n = 1:N-1;
%f = n*Fs/N;
%plot(f, Y_FFT);

Fc = 4.2*10^6;              %cut off frequency
[b,a] = butter(10,Fc/(Fs/2));       % 10th order butterworth low pass filter. cut off frequency 4.2MHz
Y_filtered = filter(b,a,Y_FFT);








% receiver side
ComSig_received = Y_filtered;   %???composite signal, ?????Y  !!!!

Fc_rec = 3*10^6;    %cut off frequency at receiver side to seperate luminance and chominance
[b2,a2] = butter(10, Fc/(Fs/2));
Y_seperated = filter(b2,a2,ComSig_received);

y_rec =abs(ifft(Y_seperated));


Y_rec = zeros(obj_video.Height, obj_video.Width, numFrames_test);
m = 1;
for k = 1: numFrames_test
    for i = 1: height
        for j = 1: width
            Y_rec(i,j,k) = y_rec(m);   %(height, width, frame)
            m = m+1;
        end
    end
end

figure
for k = 1: numFrames_test
    imshow(Y_rec(:,:,k));
end



% % 1. receive the composite signal and extract Y I Q components
% rec_frame_YIQ = double(zeros(obj_video.Height, obj_video.Width, 3, numFrames));
% 
% % 2. convert YIQ space into RGB space
% rec_frame_RGB = uint8(rec_frame_YIQ);
% 
% for k = 1: numFrames - eff
%     rec_frame_RGB(:,:,:,k) = ntsc2rgb(rec_frame_YIQ(:,:,:,k));
% end
% 
% for k = 1: numFrames - eff
%     imshow(rec_frame_RGB(:,:,:,k));
% end
% 
%     



