function LFP_Lam_FOOOF(fd,lfp,states)

od = pwd;

mkdir foofout\mono
mkdir foofout\bi

[pow,powall,fx] = LFP_FFT(lfp,states,2.5);
cd([fd '\foofout\mono'])
save('LFPPow.mat','pow','powall','fx')
system(['python C:\Users\Loomis\Documents\Scripts\foof2mat.py ' ['"' fd '\foofout\mono\LFPPow.mat"']])

if length(lfp.label)>66
        lfp=LFP_ChanDownsamp_Mean_DualLam(lfp,32);
    else
        lfp=LFP_ChanDownsamp_Mean(lfp,32);
end
lfp.trial{1}(1:end-1,:) = diff(lfp.trial{1});
cfg=[]; cfg.channel = lfp.label(1:(end-1)); lfp = ft_preprocessing(cfg,lfp);
[pow,powall,fx] = LFP_FFT(lfp,states,2.5);
cd([fd '\foofout\bi'])
save('LFPPowBi.mat','pow','powall','fx')
system(['python C:\Users\Loomis\Documents\Scripts\foof2mat.py ' ['"' fd '\foofout\bi\LFPPowBi.mat"']])
cd(od)
end