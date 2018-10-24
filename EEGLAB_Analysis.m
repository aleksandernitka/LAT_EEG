clear all;
close all;
clc;

%% Options
os = 'mac';


%% Setup file locations
subject_list = {'LAT_1','LAT_101'};
nsubj = length(subject_list); % number of subjects

% Create dir for processed data
if ~exist('ERP', 'dir')
    mkdir('ERP')
end

if os == 'mac'
    home_path  = '/Users/aleksandernitka/Documents/GitHub/LAT_EEG';
    raw_data_path  = [home_path , '/RAW/'];
    processed_data_path = [home_path, '/ERP/'];
else
    home_path = 'C:\Users\aln318\Documents\MATLAB\';
    raw_data_path  = [home_path , '\RAW\'];
    processed_data_path = [home_path, '\ERP\'];
end

%% Import data and save as set

for s = 1:length(subject_list)
    
    % import raw data
    EEG = pop_loadbv([raw_data_path], [subject_list{s} '.vhdr']);
    EEG.setname = subject_list{s};
    
    % save file
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', processed_data_path);
    fprintf(['\nSaved ', EEG.setname, '.set\n']);
end



%% Set AR parameters for subjects
% Moving Window peak-to-peak
p2p_thrs = [80 80];
% Step-like
sl_thrs = [20 20];
sl_step = [20 20];


%% Processing for each subject

for s = 1:length(subject_list)
    
    fprintf(['\n\n Processing ', subject_list{s}, '\n\n']);
    
    %Load the EEG
    EEG = pop_loadset([subject_list{s} '.set'], processed_data_path);
    
    %% Pre-Process
    
    % Downsample
    %EEG = pop_resample( EEG, 250);
    
    % Re-reference
    EEG = pop_eegchanoperator( EEG, {  'nch1 = ch1 - ( ch32 *.5 ) Label Fp1',  'nch2 = ch2 - ( ch32 *.5 ) Label Fp2',  'nch3 = ch3 - ( ch32 *.5 ) Label F3',...
        'nch4 = ch4 - ( ch32 *.5 ) Label F4',  'nch5 = ch5 - ( ch32 *.5 ) Label F7',  'nch6 = ch6 - ( ch32 *.5 ) Label F8',...
        'nch7 = ch7 - ( ch32 *.5 ) Label FC5',  'nch8 = ch8 - ( ch32 *.5 ) Label FC6',  'nch9 = ch9 - ( ch32 *.5 ) Label C3',  'nch10 = ch10 - ( ch32 *.5 ) Label C4',...
        'nch11 = ch11 - ( ch32 *.5 ) Label T7',  'nch12 = ch12 - ( ch32 *.5 ) Label T8',  'nch13 = ch13 - ( ch32 *.5 ) Label CP5',...
        'nch14 = ch14 - ( ch32 *.5 ) Label CP6',  'nch15 = ch15 - ( ch32 *.5 ) Label P3',  'nch16 = ch16 - ( ch32 *.5 ) Label P4',  'nch17 = ch17 - ( ch32 *.5 ) Label P7',...
        'nch18 = ch18 - ( ch32 *.5 ) Label P8',  'nch19 = ch19 - ( ch32 *.5 ) Label PO3',  'nch20 = ch20 - ( ch32 *.5 ) Label PO4',...
        'nch21 = ch21 - ( ch32 *.5 ) Label PO7',  'nch22 = ch22 - ( ch32 *.5 ) Label PO8',  'nch23 = ch23 - ( ch32 *.5 ) Label O1',...
        'nch24 = ch24 - ( ch32 *.5 ) Label O2',  'nch25 = ch25 - ( ch32 *.5 ) Label Fz',  'nch26 = ch26 - ( ch32 *.5 ) Label Cz',  'nch27 = ch27 - ( ch32 *.5 ) Label Pz',...
        'nch28 = ch28 - ( ch32 *.5 ) Label Oz',  'nch29 = ch29 - ( ch32 *.5 ) Label LHEOG',  'nch30 = ch30 - ( ch32 *.5 ) Label RHEOG',...
        'nch31 = ch31 - ( ch32 *.5 ) Label VEOG',  'nch32 = ch32 Label LM' } , 'ErrorMsg', 'popup', 'Warning',...
        'on' );
    
    % high pass filter to remove drift, 1hz
    EEG = pop_eegfiltnew(EEG, 'locutoff', 1,'plotfreqz', 0);
    
    % Channel locations
    EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    
    % Save file
    EEG = saveMyEEG(EEG, 'PrePro', processed_data_path);
    
    %% EventList, Binlister & Epoch
    
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        [processed_data_path  subject_list{s} '_elist.txt']);
    
    % Binlister
    % BIN STRUCTURES LEGEND
    % bin_structure1.txt = 12 bins; cue + target L/R/C + distr L/R/C
    % bin_structure2.txt = 6 bins; cue + target C/Latt + distr C/Latt
    % bin_structure3.txt = 6 bins; as 2 but only correct responses.
    
    which_binStructure = 'bin_structure1.txt';
    
    EEG  = pop_binlister( EEG , 'BDF', which_binStructure, 'ExportEL',...
        [processed_data_path subject_list{s} '_elist_binned.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput',...
        'EEG' );
    
    % Epoching and base correction
    EEG = pop_epochbin( EEG , [-200.0  800.0],  'pre');
    
    % Save data
    EEG = saveMyEEG(EEG, 'Binned', processed_data_path);
    
    %% ArtRej

    % To reset the flags:
    % EEG  = pop_resetrej( EEG , 'ArtifactFlag',  1:8, 'ResetArtifactFields', 'on', 'UserFlag',  1:8 );
    
    % Moving Window peak-to-peak (EOG only) = FLAG 2
    EEG  = pop_artmwppth( EEG , 'Channel',  29:31, 'Flag', [ 1 2], 'Threshold',  p2p_thrs(s), 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
        100 );
    
    % Step-like (EOG only) = FLAG 3
    EEG  = pop_artstep( EEG , 'Channel',  29:31, 'Flag', [ 1 3], 'Threshold',  sl_thrs(s), 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
        sl_step(s) );
    
    % AR Summary print and save to file
    [EEG, tprej, acce, rej, histoflags ] = pop_summary_AR_eeg_detection(EEG,'none');
    EEG = pop_summary_AR_eeg_detection(EEG, [processed_data_path subject_list{s}, '_AR_details.txt']);
    
    % Sync markers to EEGLAB structure, doesnt always work
    %EEG = pop_syncroartifacts(EEG, 3);
    
    % save file
    EEG = saveMyEEG(EEG, 'ar', processed_data_path);
    
end


%% Make ERP

for s = 1:length(subject_list)
    
    % Load data
    EEG = pop_loadset([subject_list{s} '_PrePro_Binned_ar.set'], processed_data_path);
    
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
    
    
    %% Plot ERPs - subject level
    
    % Plot 1 - ERP Contra
    ERP = pop_ploterps( ERP,  1:2:11,  15:2:23 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'no', 'Box', [ 5 1], 'ChLabel',...
        'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' , 'c-' ,...
        'm-' }, 'LineWidth',  1, 'Maximize', 'on', 'Position', [ 98.6429 23.4048 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',...
        0, 'xscale', [ -200.0 798.0   -200:200:600 ], 'YDir', 'normal' );
    
    ERP = pop_exporterplabfigure( ERP, 'Filepath', processed_data_path ,'Format', 'pdf', 'Resolution',  300,...
        'SaveMode', 'auto', 'Tag', {'ERP_figure'} );
    
    close all;
    % Plot 2 - ERP Differences (ipsi-contra)
    ERP = pop_ploterps( ERP,  13:18,  15:2:23 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'no', 'Box', [ 5 1], 'ChLabel',...
        'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' , 'c-' ,...
        'm-' }, 'LineWidth',  1, 'Maximize', 'on', 'Position', [ 98.6429 23.4048 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',...
        0, 'xscale', [ -200.0 798.0   -100:100:400 ], 'YDir', 'normal' );
    
    ERP = pop_exporterplabfigure( ERP, 'Filepath', processed_data_path ,'Format', 'pdf', 'Resolution',  300,...
        'SaveMode', 'auto', 'Tag', {'ERP_figure'} );
    close all;
    
end
   
