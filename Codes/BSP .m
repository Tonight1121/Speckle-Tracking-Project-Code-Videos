%% READ THE AVI and convert to matrix
path(path,'/Users/samuelsklar/Documents/Classwork/Ultrasound/Project/Videos');
v=VideoReader('Vid3.avi');
numFrames = ceil(v.FrameRate*v.Duration);
length=345;
width=354;
mid=ceil([length,width]./2);
mat=zeros(length,width,numFrames);
vidfile = VideoWriter('newfile2.avi','Motion JPEG AVI');
vidfile.FrameRate = 2;
open(vidfile);
for i=1:numFrames
    vidFrame = readFrame(v);
    I = rgb2gray(vidFrame);
    mat(:,:,i)=im2double(I);
end
mask=zeros(size(mat(:,:,1)));
for i=1:length
    for k=1:width
        check=((i-mid(1)+30).^2)+((k-mid(2)+30).^2);
        if check<1.2e4
            mask(i,k)=1;
        end
    end
end
for i=1:length
    for k=1:width
        check=((i-mid(1)+30).^2)+((k-mid(2)+30).^2);
        if check<.2e4
            mask(i,k)=0;
        end
    end
end

border=40;
%% Define the different check sizes to be used
%checks=[5,10,15,20,25,30,35];
%checks=[9:10];
%checks=1:35;
checks=[35]; 
checksizes=[-1,1]'*checks;
checksizes=checksizes';
pyms=size(checksizes,1);
pyind=zeros(size(checksizes));
for i=1:pyms
    pyind(i,:)=[checks(end)-checks(i)+1,checks(end)+checks(i)+1];
end
% Run throught calculations
tic
for f=1:1:numFrames-58
ydiff=zeros(length-2*border,width-2*border);
xdiff=zeros(length-2*border,width-2*border);
    f
    for i=1+border:10:length-border
        posi=checksizes+i;
        for k=1+border:10:width-border
            posk=checksizes+k;
            if mask (i,k) == 1
                refp=mat(posi(end,1):posi(end,2),posk(end,1):posk(end,2),f);
                mSAD=inf;
                fst=1;
                    for j=[0,-1,1,-2,2,-3,3,-4,4,-5,5]
                        cposi=posi+j;
                        for m=[0,-1,1,-2,2,-3,3,-4,4,-5,5]
                            cposk=posk+m;
                            if fst==1
                               SAD=sum(sum(abs(refp(pyind(end,1):pyind(end,2),pyind(end,1):pyind(end,2))-...
                                          mat(cposi(end,1):cposi(end,2),cposk(end,1):cposk(end,2),f+1))));
                                mSAD=SAD;
                                ydiff(i,k)=j;
                                xdiff(i,k)=m;
                                fst=0;
                                else
                                for py=1:pyms
                                      SAD=sum(sum(abs(refp(pyind(py,1):pyind(py,2),pyind(py,1):pyind(py,2))-...
                                          mat(cposi(py,1):cposi(py,2),cposk(py,1):cposk(py,2),f+1))));
                                    if SAD>mSAD
                                        break
                                    elseif py==pyms
                                        mSAD=SAD;
                                        ydiff(i,k)=j;
                                        xdiff(i,k)=m;
                                    end
                                end
                            end
                        end
                    end
            end
        end
    end
    %% Write video
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