clc;close all;clear all

% reading video 
video = VideoReader('highway.avi');

%getting the number of frames (30 frames)
frames=get(video,'NumberOfFrames');

% converting from avi format to struct 
video = read(video);

% seperating frames
for i = 1:frames
    all_frames(i).cdata = video(:,:,:,i); 
    
end


% defining variables
probabilities = [0.0001,0.001,0.01,0.1,0.2];
BER_NO_CHANNEL_CODING = zeros(5);
BER_OF_CHANNEL_CODING_WITH_RATE_HALF = zeros(5);
BER_OF_CHANNEL_CODING_WITH_RATE_INCREMENTAL = zeros(5);
TOTAL_RATE_FOR_INCREMENTAL_REDUNDENCY = zeros(5);
% calling functions to generate required videos
for i = 1:5
    %BER_NO_CHANNEL_CODING(i) = no_channel_coding(probabilities(i),all_frames);
    BER_OF_CHANNEL_CODING_WITH_RATE_HALF(i)=channel_Coding_with_rate_half(probabilities(i),all_frames);
    %[BER_OF_CHANNEL_CODING_WITH_RATE_INCREMENTAL(i),TOTAL_RATE_FOR_INCREMENTAL_REDUNDENCY(i)] =channel_coding_with_upgrading_rate(probabilities(i),all_frames);
end

% plotting against different probabilities of error
%plot(probabilities,BER_NO_CHANNEL_CODING);
plot(probabilities,BER_OF_CHANNEL_CODING_WITH_RATE_HALF);
%plot(probabilities,BER_OF_CHANNEL_CODING_WITH_RATE_INCREMENTAL);
%figure
%plot(probabilities,TOTAL_RATE_FOR_INCREMENTAL_REDUNDENCY);