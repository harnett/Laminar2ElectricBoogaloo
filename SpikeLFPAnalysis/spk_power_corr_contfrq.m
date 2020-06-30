function powcall = spk_power_corr_contfrq(unitdata,sfrq)

% get dn
for k = 1 : length(unitdata)
    spk(k).time = unitdata(k).ts;
end

[dn,~] = binspikes(spk,1000);

dn(dn>=1) = 1;

dn = cont_to_segment(dn,5000);

dn = squeeze(sum(dn))';

dn = [dn; zeros(5,size(dn,2))]; % pad dn with zeros just in case lfp exceeds spikes

% get power spectra at each bin
for k = 1 : 3
    tic
    for kk = 1 : 3
        if kk == 1
            gs=sfrq{k,kk}.cfg.previous.trials;
        elseif kk == 2
            gs=sfrq{k,kk}.cfg.previous.previous.previous.trials; 
        elseif kk == 3
            gs=sfrq{k,kk}.cfg.previous.previous.previous.previous.trials;
        end
         dn2 = dn(gs,:);
         
       powc = zeros(size(sfrq{k,kk}.powspctrm,2),size(sfrq{k,kk}.powspctrm,3),length(unitdata)); %64 2500 47
        for i = 1 : size(sfrq{k,kk}.powspctrm,2)
            for ii = 1 : size(sfrq{k,kk}.powspctrm,3)
                c = corr([ squeeze(sfrq{k,kk}.powspctrm(:,i,ii)) dn2]);
                c = c(1,2:end);
                powc(i,ii,:) = squeeze(c);
            end
        end
    powcall{k,kk} = powc;
    end
    toc
    disp(k)
end

fq_ax = sfrq{1,1}.freq;

if ~isempty(sdir)
if ~exist([sdir '/analysis_out'], 'dir')
    mkdir([sdir '/analysis_out'])
else
    cd([sdir '/analysis_out'])
end
save('powc.mat','fq_ax','powcall','-v7.3')
end

end