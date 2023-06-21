function [normed_vol mea st n]=norm_inside_mask(vol,mask)

% quick and dirty
% sum(sum(sum(mona_mask.*(mask~=0))))./sum(sum(sum(mask~=0)))
% n=0;
% s=0;
% for x=1:size(vol,1)
%     for y=1:size(vol,2)
%         for z=1:size(vol,3)
%             if mask(x,y,z)~=0
%                 n=n+1;
%                 s=s+vol(x,y,z);
%             end;
%         end;
%     end;
% end;
% mea=s./n;

mask=mask~=0;

n=sum(sum(sum(mask~=0)));
mea=sum(sum(sum((vol.*mask).*(vol~=0))))./n;
st=sqrt(sum(sum(sum((((mask==0).*mea)+(vol.*mask) -mea).^2)))./n);
normed_vol=(vol-mea)./st;