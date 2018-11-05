clear all;
close all;
clc;

%% Options
os = 'mac';

% Determine which steps of the analysis to run/re-run
importRawData = true;
preprocessData = true;
runAR = true;
createParticERPs = false;
plotPaarticERP = true;
contructGrandMeans = true;
plotGrandMeans = true;


%% Setup file locations
subject_list = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
nsubj = length(subject_list); % number of subjects

% Create dir for processed data and plots
% if ~exist('ERP', 'dir')
%     mkdir('ERP');
% end
%
% if ~exist('PLT', 'dir')
%     mkdir('PLT');
% end

if os == 'mac'
    home_path = '/Users/aleksandernitka/Documents/GitHub/LAT_EEG';
    file_path = '/Volumes/128gb/LAT_EEG';
    raw_data_path  = [file_path , '/RAW/'];
    processed_data_path = [file_path, '/ERP/'];
    plots_data_path = [file_path, '/PLT/'];
else
    home_path = 'C:\Users\aln318\Documents\MATLAB\';
    raw_data_path  = [home_path , '\RAW\'];
    processed_data_path = [home_path, '\ERP\'];
    plots_data_path = [home_path, '\PLT\'];
end

%% Import data and save as set
% only import to *.set filetype

importList = {'LAT_4', 'LAT_5', 'LAT_6'};

ImportVHDR2SET(importList, raw_data_path, processed_data_path);

%% Processing for each subject

preprocessList = {'LAT_4'};
epochLen = [-200 800];
binlisterFile = 'bin_structure1.txt';

% BIN STRUCTURES LEGEND
% bin_structure1.txt = 12 bins; cue + target L/R/C + distr L/R/C
% bin_structure2.txt = 6 bins; cue + target C/Latt + distr C/Latt
% bin_structure3.txt = 6 bins; as 2 but only correct responses.

PreProcessEEG(preprocessList, processed_data_path, processed_data_path, binlisterFile, ...
    epochLen, true);


%% Artifact Rejection

if (runAR)
    
    % Set AR parameters for subjects
    % Moving Window peak-to-peak
    p2p_thrs = [80 130 80 80];
    % Step-like
    sl_thrs = [40 40 40 40];
    sl_step = [20 20 20 20];
    
    for s = 1:length(subject_list)
        
        fprintf(['\n\n Processing ', subject_list{s}, '\n\n']);
        
        %Load the EEG
        EEG = pop_loadset([subject_list{s} '_Binned.set'], processed_data_path);
        
        % To reset the flags:
        % EEG  = pop_resetrej( EEG , 'ArtifactFlag',  1:8, 'ResetArtifactFields', 'on', 'UserFlag',  1:8 );
        
        % Moving Window peak-to-peak (EOG and fraontal electrodes only) = FLAG 2
        thisP2Pth = p2p_thrs(s);
        EEG  = pop_artmwppth( EEG , 'Channel',  [1:6 29:31], 'Flag', [ 1 2], 'Threshold',  thisP2Pth, 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
            100 );
        
        % Step-like (EOG only) = FLAG 3
        thisSLth = sl_thrs(s);
        thisSLws = sl_step(s);
        EEG  = pop_artstep( EEG , 'Channel',  29:31, 'Flag', [ 1 3], 'Threshold', thisSLth , 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
            thisSLws);
        
        pop_eegplot( EEG, 1, 1, 1);
        
        fprintf(['\n\n Displaying raw data and AR markers for ', subject_list{s}, '\n\n PRESS ANY KEY TO CONTINUTE...']);
        pause;
        
        % AR Summary print and save to file
        [EEG, tprej, acce, rej, histoflags ] = pop_summary_AR_eeg_detection(EEG,'none');
        EEG = pop_summary_AR_eeg_detection(EEG, [processed_data_path subject_list{s}, '_AR_details.txt']);
        
        % Sync markers to EEGLAB structure, doesnt always work
        %EEG = pop_syncroartifacts(EEG, 3);
        
        % save file
        EEG = saveMyEEG(EEG, 'ar', processed_data_path);
        
    end
    
end
%% Make ERP

if (createParticERPs)
    
    for s = 1:length(subject_list)
        
        % Load data
        EEG = pop_loadset([subject_list{s} '_Binned_ar.set'], processed_data_path);
        
        % average without rejected trials
        ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'off' );
        
        % save erp as file
        ERP = pop_savemyerp(ERP, 'erpname', '1', 'filename',...
            [processed_data_path  subject_list{s}, '_erp.erp'], 'Warning', 'off');
        
        % BIN OPS - create ipsi/contra bins
        ERP = pop_binoperator( ERP, {  'prepareContraIpsi',...
            'Lch = [ 1:2:25 26:32]',  'Rch = [ 2:2:24 25:32]',  ...
            'nbin1 = 0.5*bin1@Rch + 0.5*bin2@Lch label NEUTRAL_TARGET_LAT Contra',...
            'nbin2 = 0.5*bin1@Lch + 0.5*bin2@Rch label NEUTRAL_TARGET_LAT Ipsi',...
            'nbin3 = 0.5*bin3@Rch + 0.5*bin4@Lch label NEUTRAL_DISTR_LAT Contra',...
            'nbin4 = 0.5*bin3@Lch + 0.5*bin4@Rch label NEUTRAL_DISTR_LAT Ipsi',...
            'nbin5 = 0.5*bin5@Rch + 0.5*bin6@Lch label POSITIVE_TARGET_LAT Contra',...
            'nbin6 = 0.5*bin5@Lch + 0.5*bin6@Rch label POSITIVE_TARGET_LAT Ipsi',...
            'nbin7 = 0.5*bin7@Rch + 0.5*bin8@Lch label POSITIVE_DISTR_LAT Contra',...
            'nbin8 = 0.5*bin7@Lch + 0.5*bin8@Rch label POSITIVE_DISTR_LAT Ipsi',...
            'nbin9 = 0.5*bin9@Rch + 0.5*bin10@Lch label NEGATIVE_TARGET_LAT Contra',...
            'nbin10 = 0.5*bin9@Lch + 0.5*bin10@Rch label NEGATIVE_TARGET_LAT Ipsi',...
            'nbin11 = 0.5*bin11@Rch + 0.5*bin12@Lch label NEGATIVE_DISTR_LAT Contra',...
            'nbin12 = 0.5*bin11@Lch + 0.5*bin12@Rch label NEGATIVE_DISTR_LAT Ipsi',...
            });
        
        % BIN OPS - create ipsi-contra bins
        ERP = pop_binoperator( ERP, {  ...
            'nbin1 = bin1 label NEUTRAL_TARGET_LAT Contra',...
            'nbin2 = bin2 label NEUTRAL_TARGET_LAT Ipsi',...
            'nbin3 = bin3 label NEUTRAL_DISTR_LAT Contra',...
            'nbin4 = bin4 label NEUTRAL_DISTR_LAT Ipsi',...
            'nbin5 = bin5 label POSITIVE_TARGET_LAT Contra',...
            'nbin6 = bin6 label POSITIVE_TARGET_LAT Ipsi',...
            'nbin7 = bin7 label POSITIVE_DISTR_LAT Contra',...
            'nbin8 = bin8 label POSITIVE_DISTR_LAT Ipsi',...
            'nbin9 = bin9 label NEGATIVE_TARGET_LAT Contra',...
            'nbin10 = bin10 label NEGATIVE_TARGET_LAT Ipsi',...
            'nbin11 = bin11 label NEGATIVE_DISTR_LAT Contra', ...
            'nbin12 = bin12 label NEGATIVE_DISTR_LAT Ipsi', ...
            'nbin13 = bin1 - bin2 label NEUTRAL_TARGET_LAT Contra-Ipsi',...
            'nbin14 = bin3 - bin4 label NEUTRAL_DISTR_LAT Contra-Ipsi',...
            'nbin15 = bin5 - bin6 label POSITIVE_TARGET_LAT Contra-Ipsi',...
            'nbin16 = bin7 - bin8 label POSITIVE_DISTR_LAT Contra-Ipsi',...
            'nbin17 = bin9 - bin10 label NEGATIVE_TARGET_LAT Contra-Ipsi',...
            'nbin18 = bin11 - bin12 label NEGATIVE_DISTR_LAT Contra-Ipsi'});
        
        % Remove ERP baseline
        ERP = pop_blcerp( ERP , 'Baseline', 'pre', 'Saveas', 'off' );
        
        % 60Hz low pass filter for the ERP
        ERP = pop_filterp( ERP,  1:32 , 'Cutoff',  60, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
        
        % Save the ERP
        ERP = pop_savemyerp(ERP,...
            'erpname', [subject_list{s} '_filter_binOps'], 'filename', [processed_data_path  subject_list{s} '_filter_binOps.erp'], 'Warning', 'off');
        
    end
    
end

%% Plot ERPs - subject level

if (plotPaarticERP)
    
    for s = 1:length(subject_list)
        
        ERP = pop_loaderp( 'filename', [subject_list{s} '_filter_binOps.erp'], 'filepath', 'ERP/' );
        
        Bins2Plot = {[1 2], [3 4], [5 6], [7 8], [9 10], [11 12]};
        
        Names2Plot = {...
            'NEUTRAL_TARGET_LAT',...
            'NEUTRAL_DISTR_LAT',...
            'POSITIVE_TARGET_LAT',...
            'POSITIVE_DISTR_LAT',...
            'NEGATIVE_TARGET_LAT',...
            'NEGATIVE_DISTR_LAT '};
        
        for n = 1:length(Bins2Plot)
            ERP.erpname = [subject_list{s} '_' Names2Plot{n}];
            plotMyERP(ERP, Bins2Plot{n}, false, true, plots_data_path);
            ERP.erpname = 'meanERP';
        end
        
    end
end

%% GRAND MEANS
if (contructGrandMeans)
    
    %Construct mean ERP, see grandMeanList.txt for list of ERP sets used
    ERP = pop_gaverager( 'grandMeanList.txt' , 'ExcludeNullBin', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP,...
        'erpname', 'meanERP', 'filename', 'meanERP.erp', 'filepath', 'ERP', 'Warning', 'off');
    
    
end

if (plotGrandMeans)
    
    % Load the ERP
    ERP = pop_loaderp( 'filename', 'meanERP.erp', 'filepath', 'ERP/' );
    
    
    %% ERP plots
    
    Bins2Plot = {[1 2], [3 4], [5 6], [7 8], [9 10], [11 12]};
    Names2Plot = {...
        'NEUTRAL_TARGET_LAT',...
        'NEUTRAL_DISTR_LAT',...
        'POSITIVE_TARGET_LAT',...
        'POSITIVE_DISTR_LAT',...
        'NEGATIVE_TARGET_LAT',...
        'NEGATIVE_DISTR_LAT '};
    
    for s = 1:length(Bins2Plot)
        ERP.erpname = ['MeanERP_' Names2Plot{s}];
        plotMyERP(ERP, Bins2Plot{s}, false, true, plots_data_path);
        ERP.erpname = 'meanERP';
    end
    
    %% DIFF plots
    Bins2Plot = {[13 14], [15 16], [17 18]};
    Names2Plot = {...
        'MeanERP_NEUTRAL_Diff',...
        'MeanERP_POSITIVE_Diff',...
        'MeanERP_NEGATIVE_Diff'};
    
    for s = 1:length(Bins2Plot)
        ERP.erpname = Names2Plot{s};
        plotMyERP(ERP, Bins2Plot{s}, false, true, plots_data_path);
        ERP.erpname = 'meanERP';
    end
end