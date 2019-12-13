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
checksize=130;
tic
for i=1+border:10:length-border
   % i
%     if i>mid(2)
%         ore(2)=-1;
%     end
    posi=[i,i+ore(2)*checksize];
    if posi(2)<posi(1)
        posi=[posi(2),posi(1)];
    end
    for k=1+border:10:width-border
%         if k>mid(1)
%             ore(1)=-1;
%         end
        posk=[k,k+ore(1)*checksize];
        if posk(2)<posk(1)
            posk=[posk(2),posk(1)];
        end
        ref=A(posi(1):posi(2),posk(1):posk(2));
        mSAD=inf;
            for j=-5:5
                cposi=posi+j;
                for m=-5:5
                    cposk=posk+m;
                    SAD=sum(sum(abs(ref-...
                        Amod(cposi(1):cposi(2),cposk(1):cposk(2)))));
                    if SAD<mSAD
                        mSAD=SAD;
                        ydiff(i,k)=j;
                        xdiff(i,k)=m;
                    end
                end
            end
        ore(1)=1;
    end
    ore(2)=1;
end
toc
%%
figure;
quiver(1:size(xdiff,2),1:size(xdiff,1),xdiff,ydiff)
set(gca, 'YDir','reverse')
imagesc(A);
colormap(gray);