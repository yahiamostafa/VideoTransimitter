function BER = channel_Coding_with_rate_half(p,all_frames)
frames = length(all_frames);
s= size(all_frames(1).cdata);
new_video(1:frames) =struct ('cdata', zeros(s(1),s(2),3,'uint8'), 'colormap',[]);
% Creating Trellis for encoding and decoding.
trellis= poly2trellis(7,[171 133]);
mul = 2048;
difference =0;
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
    for pkt =1 :pkts
        
        % encoding packets  
        Rencodded((pkt-1)*mul+1:pkt*mul) = convenc(Rbin((pkt-1)*1024+1:pkt*1024),trellis);
        Gencodded((pkt-1)*mul+1:pkt*mul) = convenc(Gbin((pkt-1)*1024+1:pkt*1024),trellis);
        Bencodded((pkt-1)*mul+1:pkt*mul) = convenc(Bbin((pkt-1)*1024+1:pkt*1024),trellis);
        % add noise to the packets
        Rencodded((pkt-1)*mul+1:pkt*mul)=bsc(Rencodded((pkt-1)*mul+1:pkt*mul),p);
        Gencodded((pkt-1)*mul+1:pkt*mul)=bsc(Gencodded((pkt-1)*mul+1:pkt*mul),p);
        Bencodded((pkt-1)*mul+1:pkt*mul)=bsc(Bencodded((pkt-1)*mul+1:pkt*mul),p);
        % decoding the packets
        Rerror((pkt-1)*1024+1:pkt*1024) = vitdec(Rencodded((pkt-1)*mul+1:pkt*mul),trellis,35,'trunc','hard');
        Gerror((pkt-1)*1024+1:pkt*1024) = vitdec(Gencodded((pkt-1)*mul+1:pkt*mul),trellis,35,'trunc','hard');
        Berror((pkt-1)*1024+1:pkt*1024) = vitdec(Bencodded((pkt-1)*mul+1:pkt*mul),trellis,35,'trunc','hard');
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
if (p==0.001)
v = VideoWriter('0.5_channel_coding_with_error_probability_0.001.avi','Uncompressed AVI');
open(v);
writeVideo(v,new_video);
close(v);
else if (p==0.1)
    v = VideoWriter('0.5_channel_coding_with_error_probability_0.1.avi','Uncompressed AVI');
    open(v);
    writeVideo(v,new_video);
    close(v);
end
end

