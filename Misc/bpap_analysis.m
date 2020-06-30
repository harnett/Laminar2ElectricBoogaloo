function [va,vb,numchs_above,numchs_below,bp] = bpap_analysis(unitdata)

va=[]; vb=[]; ar=[]; br=[];
fsrs = vertcat(unitdata(:).fsrs);
for k = 1 : length(unitdata)
    w = unitdata(k).waveform_mean(:,96:106);
    sCh = unitdata(k).ch;
    if sCh>32
        sCh = sCh-32;
    end
    if w(sCh,6)<0
        w = -w;
    end
    
    w = w - repmat(mean(w,2),[1 size(w,2)]);
    
    [maxv,maxio] = max(w');
    maxi=maxio;
    ch_sprd = maxv >= (.4*maxv(sCh));
    
    c = contiguous(ch_sprd,1); c=c{1,2};
    
    for kk = 1 : size(c,1)
        if ~isempty(intersect(c(kk,1):c(kk,2),sCh))
            ch_sprd = c(kk,1):c(kk,2); break
        end
    end
    
    ch_sprdo = ch_sprd;
    
    maxi = maxi(ch_sprd)-101;
    
    ch_sprd = abs(ch_sprd - sCh);
    
    ch_sprd_cent = find(ch_sprd==0);
    
    %[vel_bel,vel_bel_err] = polyfit(ch_sprd(1:ch_sprd_cent),maxi(1:ch_sprd_cent),1);
    [vel_abv,vel_abv_err] = polyfit(maxi(1:ch_sprd_cent),ch_sprd(1:ch_sprd_cent),1);
    artmp = vel_abv_err.normr; 
    numchs_above(k) = length(ch_sprd(1:ch_sprd_cent))-1;
    if numchs_above(k) <=1
        vel_abv = nan; 
        artmp = nan;
    end
    %[vel_abv,vel_abv_err] = polyfit(ch_sprd(ch_sprd_cent:end),maxi(ch_sprd_cent:end),1);
    [vel_bel,vel_bel_err] = polyfit(maxi(ch_sprd_cent:end),ch_sprd(ch_sprd_cent:end),1);
    numchs_below(k) = length(ch_sprd(ch_sprd_cent:end)) - 1;
    beltmp=vel_bel_err.normr;
    if numchs_below(k) <=1 
        vel_bel = nan; 
        beltmp = nan;
    end
    
    vb(k) = vel_bel(1); va(k) = vel_abv(1);
    ar(k) = artmp; br(k) = beltmp;
    
    subplot(8,9,k)
    imagesc(w), hold on
    plot(maxio(ch_sprdo),ch_sprdo,'k'), title([vb(k) va(k) length(ch_sprd)])
end
vb(vb>=5)=nan; va(va>=5)=nan;

bp = zeros(1,length(fsrs)); bp(intersect(find(va>0),find(numchs_above>=2))) = 1;

save('bpap_res.mat','va','vb','numchs_above','numchs_below','bp')