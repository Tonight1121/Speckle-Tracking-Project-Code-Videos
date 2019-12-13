%% READ THE AVI and convert to matrix
path(path,'/Users/Livvy/Documents/BME 8730');
matr=load('simulatedspec.mat');
matr=matr.Q;
A=matr(500:800,500:1000);
length=size(A,1);
width=size(A,2);
shift=[1,1];
Amod = circshift(A,shift);
% uncoment to shift in two directions
% Amod(1:150,:)=circshift(A(1:150,:),[0,1]);
% Amod(151:end,:)=circshift(A(151:end,:),[0,-1]);
border=140;
ore=[1,1];
ydiff=zeros(length-2*border,width-2*border);
xdiff=zeros(length-2*border,width-2*border);

%checks=[5,10,15,20,25,30,35];
%checks=[9:10];
%checks=1:35;
checks=[90];
checks=[10:60:130];
checksizes=[-1,1]'*checks;
checksizes=checksizes';
pyms=size(checksizes,1);
pyind=zeros(size(checksizes));
for i=1:pyms
    pyind(i,:)=[checks(end)-checks(i)+1,checks(end)+checks(i)+1];
end
tic
    for i=1+border:10:length-border
        posi=checksizes+i;
        for k=1+border:10:width-border
            posk=checksizes+k;
                refp=A(posi(end,1):posi(end,2),posk(end,1):posk(end,2));
                mSAD=inf;
                fst=1;
                    for j=[0,-1,1,-2,2,-3,3,-4,4,-5,5]
                        cposi=posi+j;
                        for m=[0,-1,1,-2,2,-3,3,-4,4,-5,5]
                            cposk=posk+m;
                            if fst==1
                               SAD=sum(sum(abs(refp(pyind(end,1):pyind(end,2),pyind(end,1):pyind(end,2))-...
                                          Amod(cposi(end,1):cposi(end,2),cposk(end,1):cposk(end,2)))));
                                mSAD=SAD;
                                ydiff(i,k)=j;
                                xdiff(i,k)=m;
                                fst=0;
                                else
                                for py=1:pyms
                                      SAD=sum(sum(abs(refp(pyind(py,1):pyind(py,2),pyind(py,1):pyind(py,2))-...
                                          Amod(cposi(py,1):cposi(py,2),cposk(py,1):cposk(py,2)))));
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
    toc
%%
figure;
quiver(1:size(xdiff,2),1:size(xdiff,1),xdiff,ydiff)
set(gca, 'YDir','reverse')
imagesc(A);
colormap(gray);