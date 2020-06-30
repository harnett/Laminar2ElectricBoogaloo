function [lgs,lgsm,lgss] = SpindleLagCalc(SSmtx)

chs = unique(SSmtx(:,1));

lgs=cell(length(chs));
for k=1:(length(chs)-1)
    %tmp=brstin{k};
    inds=1:length(chs); inds(k)=[];
    s1 = SSmtx(find(SSmtx(:,1)==chs(k)),:);
    for kk=(k+1):length(chs)
        s2 = SSmtx(find(SSmtx(:,1)==chs(kk)),:);
        for bi1=1:size(s1,1)
            b1=s1(bi1,2):s1(bi1,4);%(brstin{k}(bi1,1):brstin{k}(bi1,2));
            for bi2=1:size(s2,1)
                b2=s2(bi2,2):s2(bi2,4);%(brstin{kk}(bi2,1):brstin{kk}(bi2,2));
                if (intersect(b1,b2))
                    %if isempty(lgs{k,kk})
                    %    lgs{k,kk}=[b2(1)-b1(1)];
                    %else
                        lgs{k,kk}=[lgs{k,kk} b2(1)-b1(1)];
                    %end
                end
            end
        end
    end
end
%%
lgsm=nan(length(chs));
for k=1:length(chs)
for kk=1:length(chs)
if ~isempty(lgs{k,kk}), lgsm(k,kk)=median(squeeze(lgs{k,kk})), end;
end
end
%%
lgss=nan(length(chs));
for k=1:length(chs)
for kk=1:length(chs)
if ~isempty(lgs{k,kk}), lgss(k,kk)=signrank(squeeze(lgs{k,kk})), end;
end
end