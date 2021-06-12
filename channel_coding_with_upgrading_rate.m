function [BER,total_Rate] = channel_coding_with_upgrading_rate(p,all_frames)
frames = length(all_frames);
s= size(all_frames(1).cdata);
new_video(1:frames) =struct ('cdata', zeros(s(1),s(2),3,'uint8'), 'colormap',[]);
trellis= poly2trellis(7,[171 133]);
% rates will be used
rate = [8/9,4/5,2/3,4/7,1/2];
% punctring rules corresponding to the rate in the same index .
punct = [
    1 1 1 0 1 0 1 0 0 1 1 0 1 0 1 0; % rate 8/9 
    1 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0; % rate 4/5
    1 1 1 0 1 1 1 0 1 1 1 0 1 1 1 0; % rate 2/3
    1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 0; % rate 4/7
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]; % rate 1/2
mul = 2048;
difference =0;
total_Rate = 0;
total_number_of_bits = s(1)*s(2)*s(3)*frames*8;
for frame = 1:frames
    red = all_frames(frame).cdata(:,:,1); % red color in the ith frame.
    green = all_frames(frame).cdata(:,:,2); % green color in the ith frame.
    blue = all_frames(frame).cdata(:,:,3); % blue color in the ith frame.
    
    Rdouble = double(red);
    Gdouble = double(green);
    Bdouble = double(blue);
    
    Rbin = de2bi(Rdouble);
    Gbin = de2bi(Gdouble);
    Bbin = de2bi(Bdouble);
    
    Rbin = reshape(Rbin,[1 s(1)*s(2)*8]);
    Gbin = reshape(Gbin,[1 s(1)*s(2)*8]);
    Bbin = reshape(Bbin,[1 s(1)*s(2)*8]);
    
    pkts = length(Rbin)/1024;
    total_number_of_packets = pkts * frames;
    for pkt =1 :pkts
        % go throught all rates incase of error occured.
        for rep =1:5
            mul = 1024*(1/rate(rep));   
            Rencodded((pkt-1)*mul+1:pkt*mul) = convenc(Rbin((pkt-1)*1024+1:pkt*1024),trellis,punct(rep,:));
            Gencodded((pkt-1)*mul+1:pkt*mul) = convenc(Gbin((pkt-1)*1024+1:pkt*1024),trellis,punct(rep,:));
            Bencodded((pkt-1)*mul+1:pkt*mul) = convenc(Bbin((pkt-1)*1024+1:pkt*1024),trellis,punct(rep,:));
            
            Rencodded((pkt-1)*mul+1:pkt*mul)=bsc(Rencodded((pkt-1)*mul+1:pkt*mul),p);
            Gencodded((pkt-1)*mul+1:pkt*mul)=bsc(Gencodded((pkt-1)*mul+1:pkt*mul),p);
            Bencodded((pkt-1)*mul+1:pkt*mul)=bsc(Bencodded((pkt-1)*mul+1:pkt*mul),p);
            
            Rerror((pkt-1)*1024+1:pkt*1024) = vitdec(Rencodded((pkt-1)*mul+1:pkt*mul),trellis,35,'trunc','hard',punct(rep,:));
            Gerror((pkt-1)*1024+1:pkt*1024) = vitdec(Gencodded((pkt-1)*mul+1:pkt*mul),trellis,35,'trunc','hard',punct(rep,:));
            Berror((pkt-1)*1024+1:pkt*1024) = vitdec(Bencodded((pkt-1)*mul+1:pkt*mul),trellis,35,'trunc','hard',punct(rep,:));
            if (isequal(Rbin((pkt-1)*1024+1:pkt*1024),Rerror((pkt-1)*1024+1:pkt*1024)))
                % if no error occured add the rate to the total rate to
                % calculate the throughput
                total_Rate = total_Rate + rate(rep);
                break
            else if (rep ==5)
                    % if there is an error in rate = 1/2 just send the
                    % packet
                    total_Rate = total_Rate + 1/2;
                end
            end
        end
    end
       
    differenceR = sum(xor(Rerror,Rbin));
    differenceG = sum(xor(Gerror,Gbin));
    differenceB = sum(xor(Berror,Bbin));
    difference = differenceB+differenceG+differenceR+difference;
    if (p==0.001 || p==0.1)
        newDred = bi2de(reshape(Rerror,[s(1)*s(2),8]));
        newDred = reshape(newDred,[s(1),s(2)]);

        newDgreen = bi2de(reshape(Gerror,[s(1)*s(2),8]));
        newDgreen = reshape(newDgreen,[s(1),s(2)]);

        newDblue = bi2de(reshape(Berror,[s(1)*s(2),8]));
        newDblue = reshape(newDblue,[s(1),s(2)]);

        new_video(1,frame).cdata(:,:,1) =newDred; 
        new_video(1,frame).cdata(:,:,2) =newDgreen; 
        new_video(1,frame).cdata(:,:,3) =newDblue; 
    end
end
BER = difference/total_number_of_bits;
total_Rate = total_Rate / total_number_of_packets;
if (p==0.001)
v = VideoWriter('upgrading_rate_channel_coding_with_error_probability_0.001.avi','Uncompressed AVI');
open(v);
writeVideo(v,new_video);
close(v);
else if (p==0.1)
    v = VideoWriter('upgrading_rate_channel_coding_with_error_probability_0.1.avi','Uncompressed AVI');
    open(v);
    writeVideo(v,new_video);
    close(v);
end
end


