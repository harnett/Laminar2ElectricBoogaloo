function [Z, cue_sequences] = ArghyaDMTSParser(fn)
% Input: Path to a file
% Output: Z matrix
%         Column 1: Initiation timestamp (ms, relative to start of session)
%         Column 2: Target Cue (uv=0,green=1)
%         Column 3: Target Side (left=0, right=1)
%         Column 4: Cue presentation timestamp (ms)
%         Column 5: Stim presentation timestamp (ms)
%         Column 6: Response (correct=1,incorrect=0,miss=2)
%         Column 7: Poked (left=0, right=3, opt out = 5)
%         Column 8: Poked timestamp (ms, relative to start of session)
%         Column 9: Reward timestamp (NaN=no reward, otherwise ms)
%         Column 10: Catch trial type (0=none,1=no cue,2=no stim, 3=double cue)
%         Column 11: Cue Context (0=uv/green, 1=tones, 2=both)
%         Column 12: Distractor (0=no,1=yes)
%         Column 13: Laser (0=no, 1=yes)
%         Column 14: Laser On TS (ms)
%         Column 15: Laser Off TS (ms)

cue_sequences=[];

[behavior] = textread(fn,'%s',-1,'delimiter','\t');

% partition cell array into trials
trial_starts = cellfun(@(c) ~isempty(strfind(c,'trial available')),behavior);
trial_ind = find(trial_starts==1);
trial_ind = [trial_ind; size(trial_starts,1)];

num_trials = size(trial_ind,1)-1;
Z = NaN(num_trials,15);
validTrials = NaN(num_trials,1);
for i = 1:num_trials
    try
        trial_text = behavior(trial_ind(i):trial_ind(i+1));
        index = find(contains(trial_text,'::*'),1);
        if isempty(index)
            validTrials(i) = 0;
            continue
        else
            validTrials(i) = 1;
        end

        Z(i,1) = str2double(trial_text{2}); % init timestamp
        Z(i,2) = str2double(trial_text{index}(6)); % target cue
        Z(i,3) = str2double(trial_text{index}(4)); % target side
        Z(i,6) = str2double(trial_text{index}(12)); % response
        Z(i,7) = str2double(trial_text{index}(10)); % poked

        catch_index = find(contains(trial_text,'catch trial'));
        if ~isempty(catch_index)
          Z(i,10) = str2double(trial_text{catch_index}(end));
        else
          Z(i,10) = 0;
        end
        cue_index = find(contains(trial_text,'cue seq'),1);
        C = split(trial_text{cue_index});
        Z(i,4) = str2double(trial_text{cue_index+1}); % cue presentation ts
        %Z(i,10) = str2double(C{3}); % target cue percentage
        current_cue_sequence = num2str(C{4})-'0';
        cue_sequences = [cue_sequences; current_cue_sequence];

        stim_index = find(contains(trial_text, 'stim'),1);
        Z(i,5) = str2double(trial_text{stim_index+1}); % stim timestamp

        reward_index = find(contains(trial_text,'reward delivered'));
        if ~isempty(reward_index)
            Z(i,9) = str2double(trial_text{reward_index+1}); % reward timestamp
        end

        poked_index = find(contains(trial_text, 'poked'));
        if ~isempty(poked_index)
            Z(i,8) = str2double(trial_text{poked_index+1}); % poked timestamp
        else
            Z(i,7) = NaN;
        end


        Z(i,12) = ~isempty(find(contains(trial_text,'distractor'),1));
        
        cue_context_index = find(contains(trial_text,'cue context'));
        if ~isempty(cue_context_index)
            Z(i,11) = str2double(trial_text{cue_context_index}(end));
        end
        
        laser_on_index = find(contains(trial_text,'laser on'),1);
        laser_off_index = find(contains(trial_text, 'laser off'),1);
        if ~isempty(laser_on_index) 
            Z(i,13)= 1;
            Z(i,14) = str2double(trial_text{laser_on_index+1});
            Z(i,15) = str2double(trial_text{laser_off_index+1});
        else
            Z(i,13) = 0;
        end

    catch
        validTrials(i) = 0;
        Z(i) = NaN;
        num_errors=num_errors+1;
        disp(trial_text);
    end
end

Z = Z(logical(validTrials),:);

end
