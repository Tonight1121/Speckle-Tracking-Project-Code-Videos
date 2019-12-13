%% READ THE AVI and convert to matrix
path(path,'/Users/samuelsklar/Documents/Classwork/Ultrasound/Project/Videos');
v=VideoReader('Vid1.avi');
numFrames = ceil(v.FrameRate*v.Duration);
length=345;
width=354;
mid=ceil([length,width]./2);
mat=zeros(length,width,numFrames);
vidfile = VideoWriter('newfile2.avi','Motion JPEG AVI');
vidfile.FrameRate = 2; % Define new framerate in Hz
open(vidfile);
for i=1:numFrames
    vidFrame = readFrame(v);
    I = rgb2gray(vidFrame);
    mat(:,:,i)=im2double(I);
end
% Create mask
mask=zeros(size(mat(:,:,1)));
% Define region of interest
for i=1:length
    for k=1:width
        check=((i-mid(1)+30).^2)+((k-mid(2)+30).^2);
        if check<1.25e4
            mask(i,k)=1;
        end
    end
end
% Define region inside ROI that is not importnat
for i=1:length
    for k=1:width
        check=((i-mid(1)+30).^2)+((k-mid(2)+30).^2);
        if check<.15e4
            mask(i,k)=0;
        end
    end
end
donk=[0,-1,1,-2,2,-3,3,-4,4,-5,5]; % Position check order
%donk=[0,-2,2,-3,3-4,4]; % Position check order for skiping 1
border=40; % Border region of image to not calculate at
checksize=27;   % Size of checking region
tic
%% Loop through frames
for f=1:1:numFrames-1
ydiff=zeros(length-2*border,width-2*border); % Zero y movement matrix after each frame
xdiff=zeros(length-2*border,width-2*border); % Zero x movement matrix after each frame
    f
    for i=1+border:10:length-border
        posi=[i-checksize,i+checksize];
        for k=1+border:10:width-border
            posk=[k-checksize,k+checksize];
            if mask (i,k) == 1
                ref=mat(posi(1):posi(2),posk(1):posk(2),f);
                mSAD=inf;
                    for j=donk
                        cposi=posi+j;
                        for m=donk
                            cposk=posk+m;
                            SAD=sum(sum(abs(ref-...
                                mat(cposi(1):cposi(2),cposk(1):cposk(2),f+1))));
                            if SAD<mSAD
                                mSAD=SAD;
                                ydiff(i,k)=j;
                                xdiff(i,k)=m;
                            end
                        end
                    end
            end
        end
    end
%% Write Video
    figure('visible','off');
    imshow((mat(:,:,f)))
    hold on
    spacing=10;
    quiver(1:spacing:size(xdiff,2),1:spacing:size(xdiff,1),xdiff(1:spacing:end,1:spacing:end),ydiff(1:spacing:end,1:spacing:end),1,'color',[0 .8 0])
    set(gca, 'YDir','reverse')
    hold off
    F = getframe(gcf);
    writeVideo(vidfile, F.cdata(36:36+length,108:108+width,:));
    close
end
close(vidfile)
toc