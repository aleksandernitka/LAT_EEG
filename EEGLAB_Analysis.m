clear all;
close all;
clc;

%% Options
os = 'mac';

%% Setup file locations
subject_list = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};

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

%% Import data
% only import to *.set filetype

% Select raw files to import
importList = {};

% RUN the import module
ImportVHDR2SET(importList, raw_data_path, processed_data_path);

%% Pre-processing for each subject

% Run only below subjects
preprocessList = {};
% Specify epoch duration 
epochLen = [-200 800];
% Selecte Bin lister file
binlisterFile = 'bin_structure1.txt';

% RUN the preprocessing module
PreProcessEEG(preprocessList, processed_data_path, processed_data_path,... 
    binlisterFile, epochLen, true);


%% Artifact Rejection

%RUN peak-to-peak, args:
% arProcessList - list of subjects to process
% location_path - where the files are
% save - save or not after the AR
% save_path - where to save the files after AR
% method - p2p or step
% resetFlags - remove all AR markers
% flagId - set flag ID for all AR
% channels - what chans to run AR on
% Twindow - trial window
% windowSize - moving window size
% threshold - voltage threshold 
% plotRaw - show traces after AR, will pause the process

arProcessList = {'LAT_1'};
chans = [29:32];
trialWin = [-200 780];
windowSize = {100};
threshold = {100};

ArtRej(arProcessList, processed_data_path, true, processed_data_path,...
    'p2p', false, 2, chans, trialWin, windowSize, threshold, true);

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