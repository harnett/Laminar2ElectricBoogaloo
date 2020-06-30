%coherence matrix 30x30x100 yay

clear
load('cohtmp.mat')
coh = coh - eye(length(coh));

coh = coh(10:61,10:61);

nClust = 30;
% random initial assignments
clust_assignment = randi(nClust,[1 size(coh,1)]);

done = 0;

num_iter=0;

while done==0 %check if cluster assignments have converged

    clust_assignment_init = clust_assignment; %check assignments before looping thru all channels
    ch_update = randperm(size(coh,1));
    for c = ch_update % loop thru all channels
        next_ch=0; iter=0;
        while next_ch==0%see if this channel has 
            clust = unique(clust_assignment);
            clusta = clust_assignment(c);
            clust_energy = nan(1,length(clust));
            for clustbind = 1:length(clust)%calculate all cluster energy differentials
                clustb = clust(clustbind);
                clust_ea = coh(find(clust_assignment==clusta),find(clust_assignment==clusta)); clust_ea = clust_ea(:);
                clust_ea = sum(clust_ea) .* (-1./sqrt(length(clust_ea)));

                clust_eb = coh(find(clust_assignment==clustb),find(clust_assignment==clustb)); clust_eb = clust_eb(:);
                clust_eb = sum(clust_eb) .* (-1./sqrt(length(clust_eb)));

                clust_energy(clustbind) = clust_ea - clust_eb;
            end
        [m,i] = max(clust_energy); %find cluster where the channel would gain the most energy
        disp(length(clust))
        if m > 0
            clust_assignment(c) = i;
        else
            next_ch = 1;
        end
        iter = iter + 1;
        if iter>=1000
            next_ch = 1;
        end
        end
    end
        if clust_assignment == clust_assignment_init
            done = 1;
        end
        num_iter = num_iter+1;
end
    