% v2 was set up for DMTS sessions from 27th of septempber 2019 and beyond
%%
% addpath('C:\Users\Ralf\Downloads\Rajeev_code\Session Import')
% %addpath('C:\Users\Halassa Lab\Downloads\Rajeev_Code\ShrewAnalysis')
% addpath('C:\Users\Ralf\Downloads\')
%

addpath('Z:\Jonathan\Clustering and Basic Analysis\')
addpath('Z:\Jonathan\Session Import_new\')

%%%==== process accumulation of evidence experiments
clearvars -except A


DataLocation = 'Y:\MichaelL\DMTS\2019-09-29_18-00-36';
behaviorfilename.C1 = [ DataLocation filesep 'WTN6_Tethered500msremoved_100 and zero rep_190929.txt'];


MouseID = 'WTN6';
experimentType = 'DMTS';

behaviorfilename.C2 = behaviorfilename.C1;
%%
%experimentType = 'New';
%should be same as number of cut files

cd(DataLocation);
addpath(DataLocation);

%find valid .cut files

ValidNum = [];
close
X = dir('*.cut');
for i = 1:size(X,1)
    name = sprintf( X(i).name );
    target1 = strfind(name, 'TT');
    target2 = strfind(name, '.');
    num = name(target1+2:target2-1);
    ValidNum = [ValidNum, str2num(num)];
end

TT_to_process = sort(ValidNum);
TT_to_process = TT_to_process(1:end);

%%
%
% if ismac ==1
%     addpath('/Volumes/Data/Session Import');
%     addpath('/Users/rvrikhye/Dropbox (Personal)/Rajeev/ForShrew_curveFit')
%     addpath('/Users/rvrikhye/Dropbox (Personal)/Rajeev/Rajeev_Code/');
%     addpath('/Users/rvrikhye/Dropbox (Personal)/Rajeev/Rajeev_Code/Clustering and Basic Analysis/');
%     addpath('/Users/rvrikhye/Dropbox (Personal)/Rajeev/Rajeev_Code/Clustering and Basic Analysis/mclust-3.4/');
% elseif ismac ==0
%     addpath('Y:\Alireza\Rajeev_Code\Session Import');
%     %addpath('Y:\Alireza\Rajeev_Code\ForShrew_curveFit');
%     addpath('Y:\Alireza\Rajeev_Code')
%     addpath('Y:\Alireza\Rajeev_Code\Clustering and Basic Analysis');
%     addpath('Y:\Alireza\Rajeev_Code\Clustering and Basic Analysis\mclust-3.4');
%     addpath('Y:\Alireza\Rajeev_Code\Clustering and Basic Analysis\readcheetahdata');
%     addpath('C:\Users\Halassa Lab\Downloads\clustering and basic analysis\readcheetahdata\optogenetics toolbox')
% end;

%     if getappdata(h,'canceling')
%         break
%     end

%% Make a Temp Session

for tn = 4%TT_to_process
    extt = 1; % save to drobo;
    
    session_num =  1;
    
            Se = sessions();
            Se = add(Se,'CMO',...
                [2014 04 13 15 11 22],...
                DataLocation,...
                'Neuralynx G',32,...
                'File 6',...
                [4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4],... % channels per electrode/home
                [NaN NaN NaN NaN NaN NaN]);
    
    Fpath = Se.folder{session_num};
    figpath=strcat(Fpath, filesep, 'GlobalpeakC1_manual4');
    mkdir(figpath);
    
    
    %% Parse behavior text file.
    
    %========== Load TTL Values
    eventData = read_cheetah_data([Se.folder{session_num} filesep 'Events.nev']);
    TTLvalues = unique( eventData.TTLval );
    TTLbehave =  32; %It is 32 for sessions on the 27th 29th and 30th of septemper 2019, Otherwise it is 8. Very ealry sessions were also 32 so check that if you use early (pilot sessions)
    % TTLbehave =  32;
    TTTstim1   =  0;
    
    % TTLbehave2 = 193;
    
    
    [OutAll,OutCorrected] = DMTSParserIncludingRemovedTrials_v2(behaviorfilename.C1); %reads ther text file and produced D or Z matrix 
       
    D = OutAll(find(~isnan(OutAll(:,4))),:);
    %%  Sometimes there are too many trials in the beginning and in the end
    %  removedthem here if necessary
     % D=D(2:end-1,:); %10/07/19
       %%
    clear OutAll Out
    OutAll.ts= D(:,4) % stimulation presentation time stanp for cue onset stamp for all trials
    OutAll.initT= D(:,5)-D(:,4);% stim minus cue onset time
    OutAll.D=D;
    
    %% after removing attempted trials
     CompletedTrials=find(D(:,17));
    Out.ts= D(CompletedTrials,4) % stimulation presentation time stanp for cue onset stamp for all trials
    Out.initT= D(CompletedTrials,5)-D(CompletedTrials,4);% stim minus cue onset time
    Out.D=D(CompletedTrials,:);
    Out.tsFull= D(:,4) % stimulation presentation time stanp for cue onset stamp for all trials

    clear D
    D=Out.D;
    
    %%
    FudgeFact=1.001103772698461%1.001108444929755; % calculated from the drift in session 29/09/19
    OutAll.tsFudgeFact=OutAll.ts*FudgeFact % arduino clock is drifting. For sessions with poor alignment. This factor helps make the clocks align.
    
    eventData = read_cheetah_data([Se.folder{session_num}  filesep  'Events.nev']);
    eventDataholder = eventData;
    L.start_time = eventData.ts(find((eventData.TTLval == TTLbehave)))';
    Cuestart_time = eventData.ts(find((eventData.TTLval == 8)))'; % SHOULD BE 32???
    CompletedCuestart_time = Cuestart_time(CompletedTrials);

    Add1start_time = eventData.ts(find((eventData.TTLval == 64)))';
    Add2start_time = eventData.ts(find((eventData.TTLval == 160)))';

% Check TTLs and behaviour data 

xTTL=(L.start_time-L.start_time(end))
yTTL=ones(length(L.start_time),1)+1
xbehave=((Out.ts/1000)-Out.ts(end)/1000)
ybehave=ones(length(Out.ts/1000),1)
xbehaveAllInits=((Out.tsFull/1000)-Out.tsFull(end)/1000)
ybehaveAllInits=ones(length(Out.tsFull/1000),1)
  %xbehave=(OutAll.tsFudgeFact/1000)-OutAll.tsFudgeFact(end)/1000
 % ybehave=ones(length(OutAll.tsFudgeFact/1000),1)
xCueTTL=(Cuestart_time-L.start_time(end))
yCueTTL=ones(length(Cuestart_time),1)+2

xCueCompletedTTL=(Cuestart_time(CompletedTrials)-L.start_time(end))
yCueCompletedTTL=ones(length(Cuestart_time(CompletedTrials)),1)+2
for TTc=1:length(xTTL)
    for Cuec=1:length(xCueTTL)
        DistanceMatrix(TTc,Cuec)=round((xTTL(TTc)-xCueTTL(Cuec))*100);
    end
end
PairedMatrix=DistanceMatrix==51; % this value will change with delay size

[TTLPair,CuePair]=find(PairedMatrix==1);

SelectedxTTL=L.start_time(TTLPair)-L.start_time(end)
SelectedyTTL=ones(length(L.start_time(TTLPair)),1)+1
SelectedxCueTTL=Cuestart_time(CuePair)-L.start_time(end)
SelectedyCueyTTL=ones(length(Cuestart_time(CuePair)),1)+2

figure
 scatter(SelectedxTTL,SelectedyTTL,'r','filled')
 hold on
 text(SelectedxTTL, SelectedyTTL,num2str([1:length(SelectedxTTL)]'));

scatter(xTTL,yTTL,'r')
text(xTTL, yTTL,num2str([1:length(xTTL)]'));
hold on

% scatter(xbehaveAllInits,ybehaveAllInits,'c')
% text(xbehaveAllInits, ybehaveAllInits,num2str([1:length(xbehave)]'));

scatter(xbehave,ybehave,'b')
text(xbehave, ybehave,num2str([1:length(xbehave)]'));


scatter(xCueCompletedTTL,yCueCompletedTTL,'g','filled')
hold on
text(xCueCompletedTTL, yCueCompletedTTL,num2str([1:length(xCueCompletedTTL)]'));

scatter(xCueTTL,yCueTTL,'g')
hold on
text(xCueTTL, yCueTTL,num2str([1:length(xCueTTL)]'));

xadd1TTL=(Add1start_time-L.start_time(end))
yadd1TTL=ones(length(Add1start_time),1)+3
scatter(xadd1TTL,yadd1TTL,'c')
text(xadd1TTL, yadd1TTL,num2str([1:length(xadd1TTL)]'));

xadd2TTL=(Add2start_time-L.start_time(end))
yadd2TTL=ones(length(Add2start_time),1)+4
scatter(xadd2TTL,yadd2TTL,'m')
text(xadd2TTL, yadd2TTL,num2str([1:length(xadd2TTL)]'));
    ylim([-10 10])


figure;plot((diff(OutAll.ts/1000)))
% hold on;plot((diff(L.start_time(1:end-1))),'r--')
 hold on;plot((diff(Cuestart_time)),'r--')
 title('All attempted trials')
 
 figure;plot((diff(Out.ts/1000)))
% hold on;plot((diff(L.start_time(1:end-1))),'r--')
 hold on;plot((diff(CompletedCuestart_time)),'r--')
 title('All completed trials')
 
 
% figure
% scatter(Out.ts/1000-Out.ts(end)/1000,ones(length(Out.ts),1))
% hold on;
% hold on;scatter(L.start_time(1:end)-L.start_time(end),ones(length(L.start_time),1)+1,'r')
% % hold on;scatter(Cuestart_time-Cuestart_time(end),ones(length(Cuestart_time),1)+2,'g')
% ylim([-10 10])

%%
    
    %initT is duration of delay period
    
   % initT = 1*Out.initT; %0*Out.initT
    initT = 0; %Everything is now aligned to Cue onset

    % if Pos offset = -2 : start from 3rd timestamp (missed 2)
    %                     initT = Out.initT(3:end);
    %                     Out.ts  = Out.ts(3:end);
    %                     D = D(3:end,:);
    %
    
    [a,b,offset] = alignsignals(round(diff(Out.ts/1000)),round(diff(CompletedCuestart_time)));
    [a,b,negOff] = alignsignals(round(diff(wrev(Out.ts)/1000)),round(diff(wrev(CompletedCuestart_time))));
    
    disp(['Pos Offset = ' num2str(offset) '  Neg Offset = ' num2str(negOff)]);
    
    %% MILAN - COMPLETEDCUESTART_TIME OK???
    save('Y:\Milan\DMTS_LFP\2019-09-29_18-00-36\CueTime.mat','CompletedCuestart_time')
    %% Everything is now aligned to cue onset directly
    if negOff >= 0 && offset <= 0
        
        testDiff = CompletedCuestart_time(1:(length(CompletedCuestart_time)-negOff)) %- initT((-offset+1):(length(initT)))'/1000;
        figure(1);
        subplot(2,1,1);plot(diff(testDiff))
        subplot(2,1,2);plot(diff(Out.ts))
        
        drawnow;
        Linit.start_time = CompletedCuestart_time(1:(length(CompletedCuestart_time)-negOff))  %- initT((-offset+1):(length(initT)))'/1000;
        
        %         indexOK = Out.indexOK(1:end-4);
        %         Linit.start_time = Linit.start_time(indexOK);
        %         D = Out.D;
        %         D = D(indexOK,:);
        %         if correctFlag == 1
        %             Linit.start_time = Linit.start_time( Out.indexOK);
        %             D = Out.Dcorrected;
        %         end;
        
    end;
    
    
    if negOff < 0 && offset == 0
        Linit.start_time = CompletedCuestart_time((offset+1):length(CompletedCuestart_time)) %- initT((1):(length(initT)+negOff))'/1000;
        testDiff = CompletedCuestart_time((offset+1):length(CompletedCuestart_time)) %- initT(1:(length(initT)+negOff))'/1000;
        
        figure(1);
        subplot(3,1,1);plot(diff(testDiff))
        title('TTLs')
        
        subplot(3,1,2);plot(diff(Out.ts))
        title('behaviour matrix')
        
        subplot(3,1,3);
        plot(diff(Out.ts)./1000,'b')
        hold on
        plot(diff(testDiff),'r--')
        title('overlay')
        
        %    indexOK = Out.indexOK(1:end-1);
        
        Linit.start_time = Linit.start_time;%(indexOK);
        D = Out.D;
        %  D = D(indexOK,:);
    end;
    %%
    % all_tt_nums = [];
    %
    % names = dir('*.cut');
    % cd(Se.folder{session_num})
    % mkdir('AnalyzedFiles')
    %
    % for n = 1:length(names)
    %     nameSU = names(n).name;
    %     nameSU(strfind(nameSU,'.cut'):length(nameSU)) = [];
    %     nameSU(1:2) = [];
    %     all_tt_nums = [all_tt_nums str2num(nameSU)];
    % end
    %
    %%
    i = 0;
    names = dir('*.cut');
    n = 1:length(names);
    curr_tt_num = tn;
    Sc = spikes(Se,session_num,curr_tt_num);
    is_cluster = 1;
    m = 0;
    while is_cluster == 1
        m = m+1;
        cl_holder = cluster(Sc,m); %m is the cluster number
        is_full = max(size(cl_holder.timestamp));
        if is_full > 1
            i = i+1;
            eval(sprintf('cl%d = cluster(Sc,m)', i));
            num_seq(i,1:2) = [curr_tt_num m];
        else
            m = m-1;
            is_cluster = 0;
        end
    end
    Sc_unit_count(n,1) = curr_tt_num;
    Sc_unit_count(n,2) = m;
    
    
    clear cl_holder i curr_tt_num is_cluster is_full m n
    fprintf('....Done!\n');
    
    
    %% Sort into conditions ===================================================
    
    %this is where you really want to change things
    
    
    
    % close all
    pre = 5;
    post = 6;
    clearTrue = 0;
    lasShowVal = 1;
    baseEnds = [-0.5 0];
    filtSize = [5 2];
    postTag = 'baseline';
    
    %includeSet = [1:size(num_seq,1)];
    
    experimentType  = 'DMTS';
            
            
            % pure correct
            GreenL_corr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 0 & D(:,13) == 0);
            GreenR_corr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 1 & D(:,13) == 0 );
            Green_corr  = sort( [GreenL_corr; GreenR_corr] );
            
            % pure correct
            BlueL_corr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 0 & D(:,13) == 0 );
            BlueR_corr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 1 & D(:,13) == 0 );
            Blue_corr  = sort( [BlueL_corr; BlueR_corr] );
            
            % correct trials taking place in bouts of above 60 %  correct
            smoothedPerf=smoothdata(D(:,6),'gaussian',15); % gaussian window of 15 trials
            sixtyBoutTrials=smoothedPerf>.6;
            
            GreenL_60Threshcorr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 0 & sixtyBoutTrials==1 & D(:,13) == 0);
            GreenR_60Threshcorr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 1 & sixtyBoutTrials==1 & D(:,13) == 0);
            Green_60Threshcorr  = sort( [GreenL_60Threshcorr; GreenR_60Threshcorr] );
            
            BlueL_60Threshcorr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 0 & sixtyBoutTrials==1 & D(:,13) == 0);
            BlueR_60Threshcorr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 1 & sixtyBoutTrials==1 & D(:,13) == 0);
            Blue_60Threshcorr  = sort( [BlueL_60Threshcorr; BlueR_60Threshcorr] );
            
            % correct trials taking place in bouts above 70 % correct
            smoothedPerf=smoothdata(D(:,6),'gaussian',15); % gaussian window of 15 trials
            seventyBoutTrials=smoothedPerf>.7;
            
            GreenL_70Threshcorr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 0 & seventyBoutTrials==1 & D(:,13) == 0);
            GreenR_70Threshcorr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 1 & seventyBoutTrials==1 & D(:,13) == 0);
            Green_70Threshcorr  = sort( [GreenL_70Threshcorr; GreenR_70Threshcorr] );
            
            BlueL_70Threshcorr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 0 & seventyBoutTrials==1 & D(:,13) == 0);
            BlueR_70Threshcorr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 1 & seventyBoutTrials==1 & D(:,13) == 0);
            Blue_70Threshcorr  = sort( [BlueL_70Threshcorr; BlueR_70Threshcorr] );
            
            %%
            % only consecutive correct trials of 3 consecutive corrects
            % and only from the second trial onwards in those consecutive bouts
            
            % first find all trials in consecutive correct bouts above 3
            % consecutive corrects
            inbout=0;
            for iii=1:length(D(:,6))
                if iii<length(D(:,6))-1
                    if sum(D(iii:iii+2,6))==3
                        inbout=1;
                    end
                end
                if inbout==1
                    if D(iii,6)==0
                        inbout=0
                        ConsCorrIdx(iii)=0;
                        continue
                    end
                    ConsCorrIdx(iii)=1;
                else
                    ConsCorrIdx(iii)=0;
                end
            end
            
            %  Remove first trial in each consecutive correct run
            ConsCorrIdxNoFirst=ConsCorrIdx;
            ConsCorrIdxNoFirst(1)=0;
            for iii=2:length(D(:,6))-1
                if ConsCorrIdx(iii-1)==0
                    if ConsCorrIdx(iii+1)==1
                        ConsCorrIdxNoFirst(iii)=0;
                    end
                end
            end
            
            % Consecutive correct run correct
            GreenL_Conscorr = find( ConsCorrIdxNoFirst' == 1 & D(:,2)==1 & D(:,3) == 0 & D(:,13) == 0);
            GreenR_Conscorr = find( ConsCorrIdxNoFirst' == 1 & D(:,2)==1 & D(:,3) == 1 & D(:,13) == 0);
            Green_Conscorr  = sort( [GreenL_Conscorr; GreenR_Conscorr] );
            
            % Consecutive correct run correct
            BlueL_Conscorr = find( ConsCorrIdxNoFirst' == 1 & D(:,2)==0 & D(:,3) == 0 & D(:,13) == 0 );
            BlueR_Conscorr = find( ConsCorrIdxNoFirst' == 1 & D(:,2)==0 & D(:,3) == 1 & D(:,13) == 0 );
            Blue_Conscorr  = sort( [BlueL_Conscorr; BlueR_Conscorr] );
            
            %%
            
            % pure incorrect
            GreenL_incorr = find( D(:,6) == 0 & D(:,2)==1 & D(:,3) == 0 & D(:,13) == 0 );
            GreenR_incorr = find( D(:,6) == 0 & D(:,2)==1 & D(:,3) == 1 & D(:,13) == 0 );
            Green_incorr  = sort( [GreenL_incorr; GreenR_incorr] );
            
            % pure incorrect
            BlueL_incorr = find( D(:,6) == 0 & D(:,2)==0 & D(:,3) == 0 & D(:,13) == 0 );
            BlueR_incorr = find( D(:,6) == 0 & D(:,2)==0 & D(:,3) == 1 & D(:,13) == 0 );
            Blue_incorr  = sort( [BlueL_incorr; BlueR_incorr] );
            
            % pure laser
            GreenL_Laser = find( D(:,2)==1 & D(:,3) == 0 & D(:,13) == 1 );
            GreenR_Laser = find( D(:,2)==1 & D(:,3) == 1 & D(:,13) == 1 );
            Green_Laser  = sort( [GreenL_Laser; GreenR_Laser] );
            
            BlueL_Laser = find(D(:,2)==0 & D(:,3) == 0 & D(:,13) == 1 );
            BlueR_Laser = find(D(:,2)==0 & D(:,3) == 1 & D(:,13) == 1 );
            Blue_Laser  = sort( [BlueL_Laser; BlueR_Laser] );
            
            % laser incorrect
            GreenL_Laser_incorr = find( D(:,6) == 0 & D(:,2)==1 & D(:,3) == 0 & D(:,13) == 1 );
            GreenR_Laser_incorr = find( D(:,6) == 0 & D(:,2)==1 & D(:,3) == 1 & D(:,13) == 1 );
            Green_Laser_incorr  = sort( [GreenL_Laser; GreenR_Laser] );
            
            BlueL_Laser_incorr = find( D(:,6) == 0 & D(:,2)==0 & D(:,3) == 0 & D(:,13) == 1 );
            BlueR_Laser_incorr = find( D(:,6) == 0 & D(:,2)==0 & D(:,3) == 1 & D(:,13) == 1 );
            Blue_Laser_incorr  = sort( [BlueL_Laser; BlueR_Laser] );
            
            % laser correct
            GreenL_Laser_corr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 0 & D(:,13) == 1 );
            GreenR_Laser_corr = find( D(:,6) == 1 & D(:,2)==1 & D(:,3) == 1 & D(:,13) == 1 );
            Green_Laser_corr  = sort( [GreenL_Laser; GreenR_Laser] );
            
            BlueL_Laser_corr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 0 & D(:,13) == 1 );
            BlueR_Laser_corr = find( D(:,6) == 1 & D(:,2)==0 & D(:,3) == 1 & D(:,13) == 1 );
            Blue_Laser_corr  = sort( [BlueL_Laser; BlueR_Laser] );    
    
    
        for m = 1:48
            clear f
            if m == 1
                f = Green_corr;
                stringVal = 'Green_corr';
                stringVals{m} = stringVal;
            elseif m == 2
                f = Blue_corr;
                stringVal = 'Blue_corr';
                stringVals{m} = stringVal;
            elseif m ==3
                f = Green_60Threshcorr;
                stringVal = 'Green_60Threshcorr';
                stringVals{m} = stringVal;
            elseif m ==4
                f = Blue_60Threshcorr;
                stringVal = 'Blue_60Threshcorr';
                stringVals{m} = stringVal;
            elseif m ==5
                f = Green_70Threshcorr;
                stringVal = 'Green_70Threshcorr';
                stringVals{m} = stringVal;
            elseif m ==6
                f = Blue_70Threshcorr;
                stringVal = 'Blue_70Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 7
                f = GreenL_60Threshcorr;
                stringVal = 'GreenL_60Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 8
                f = GreenR_60Threshcorr;
                stringVal = 'GreenR_60Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 9
                f = GreenL_70Threshcorr;
                stringVal = 'GreenL_70Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 10
                f = GreenR_70Threshcorr;
                stringVal = 'GreenR_70Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 11
                f = BlueL_60Threshcorr;
                stringVal = 'BlueL_60Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 12
                f = BlueR_60Threshcorr;
                stringVal = 'BlueR_60Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 13
                f = BlueL_70Threshcorr;
                stringVal = 'BlueL_70Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 14
                f = BlueR_70Threshcorr;
                stringVal = 'BlueR_70Threshcorr';
                stringVals{m} = stringVal;
            elseif m == 15
                f = GreenL_corr;
                stringVal = 'GreenL_corr';
                stringVals{m} = stringVal;
            elseif m == 16
                f = GreenR_corr;
                stringVal = 'GreenR_corr';
                stringVals{m} = stringVal;
            elseif m == 17
                f = BlueL_corr;
                stringVal = 'BlueL_corr';
                stringVals{m} = stringVal;
            elseif m == 18
                f = BlueR_corr;
                stringVal = 'BlueR_corr';
                stringVals{m} = stringVal;
            elseif m == 19
                f = Green_incorr;
                stringVal = 'Green_incorr';
                stringVals{m} = stringVal;
            elseif m == 20
                f = Blue_incorr;
                stringVal = 'Blue_incorr';
                stringVals{m} = stringVal;
            elseif m == 21
                f = GreenL_incorr;
                stringVal = 'GreenL_incorr';
                stringVals{m} = stringVal;
            elseif m == 22
                f = GreenR_incorr;
                stringVal = 'GreenR_incorr';
                stringVals{m} = stringVal;
            elseif m == 23
                f = BlueL_incorr;
                stringVal = 'BlueL_incorr';
                stringVals{m} = stringVal;
            elseif m == 24
                f = BlueR_incorr;
                stringVal = 'BlueR_incorr';
                stringVals{m} = stringVal;
            elseif m == 25 
                f = BlueL_Conscorr;
                stringVal = 'BlueL_Conscorr';
                stringVals{m} = stringVal;
            elseif m == 26
                f = BlueR_Conscorr;
                stringVal = 'BlueR_Conscorr';
                stringVals{m} = stringVal;
            elseif m == 27 
                f = GreenL_Conscorr;
                stringVal = 'GreenL_Conscorr';
                stringVals{m} = stringVal;
            elseif m == 28
                f = GreenR_Conscorr;
                stringVal = 'GreenR_Conscorr';
                stringVals{m} = stringVal;
            elseif m == 29 
                f = Blue_Conscorr;
                stringVal = 'Blue_Conscorr';
                stringVals{m} = stringVal;
            elseif m == 30
                f = Green_Conscorr;
                stringVal = 'Green_Conscorr';
                stringVals{m} = stringVal;
            elseif m == 31 
                f = GreenL_Laser;
                stringVal = 'GreenL_Laser';
                stringVals{m} = stringVal;
            elseif m == 32
                f = GreenR_Laser;
                stringVal = 'GreenR_Laser';
                stringVals{m} = stringVal;
            elseif m == 33 
                f = BlueL_Laser;
                stringVal = 'BlueL_Laser';
                stringVals{m} = stringVal;
            elseif m == 34
                f = BlueR_Laser;
                stringVal = 'BlueR_Laser';
                stringVals{m} = stringVal;
            elseif m == 35 
                f = Blue_Laser;
                stringVal = 'Blue_Laser';
                stringVals{m} = stringVal;
            elseif m == 36
                f = Blue_Laser;
                stringVal = 'Blue_Laser';
                stringVals{m} = stringVal;
             elseif m == 37 
                f = GreenL_Laser_corr;
                stringVal = 'GreenL_Laser_corr';
                stringVals{m} = stringVal;
            elseif m == 38
                f = GreenR_Laser_corr;
                stringVal = 'GreenR_Laser_corr';
                stringVals{m} = stringVal;
            elseif m == 39 
                f = BlueL_Laser_corr;
                stringVal = 'BlueL_Laser_corr';
                stringVals{m} = stringVal;
            elseif m == 40
                f = BlueR_Laser_corr;
                stringVal = 'BlueR_Laser_corr';
                stringVals{m} = stringVal;
            elseif m == 41 
                f = Blue_Laser_corr;
                stringVal = 'Blue_Laser_corr';
                stringVals{m} = stringVal;
            elseif m == 42
                f = Blue_Laser_corr;
                stringVal = 'Blue_Laser_corr';
                stringVals{m} = stringVal;
            elseif m == 43 
                f = GreenL_Laser_incorr;
                stringVal = 'GreenL_Laser_incorr';
                stringVals{m} = stringVal;
            elseif m == 44
                f = GreenR_Laser_incorr;
                stringVal = 'GreenR_Laser_incorr';
                stringVals{m} = stringVal;
            elseif m == 45 
                f = BlueL_Laser_incorr;
                stringVal = 'BlueL_Laser_incorr';
                stringVals{m} = stringVal;
            elseif m == 46
                f = BlueR_Laser_incorr;
                stringVal = 'BlueR_Laser_incorr';
                stringVals{m} = stringVal;
            elseif m == 47 
                f = Blue_Laser_incorr;
                stringVal = 'Blue_Laser_incorr';
                stringVals{m} = stringVal;
            elseif m == 48
                f = Blue_Laser_incorr;
                stringVal = 'Blue_Laser_incorr';
                stringVals{m} = stringVal;
            end
            tr_type{m} = f;
        end
        
        save('Y:\Milan\DMTS_LFP\2019-09-29_18-00-36\TskInfo.mat','tr_type','stringVals','CompletedCuestart_time')
        