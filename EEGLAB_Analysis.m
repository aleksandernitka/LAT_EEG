clear all; 
close all; 
clc;

os = 'mac';
run_gui = false; % will open the gui and redraw after each step
runICA = false; % will run ICA, note that addittional toolbox may be required
                % see ICA section below.
                
rejectICA = false; % need to find out more about it
make_ERP = false;

eeglab; % helps with loading files from BV
%% Setup file locations
subject_list = {'LAT_1'};
nsubj = length(subject_list); % number of subjects

if os == 'mac'
    home_path  = '/Users/aleksandernitka/Documents/GitHub/LAT_EEG';
    montage = '/Users/aleksandernitka/Documents/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';
else
    home_path = 'C:\Users\aln318\Documents\MATLAB\';
    montage = 'C:\Users\aln318\Documents\MATLAB\eeglab14_1_2b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp';
end


import_data = 1;
save_files = 1;
s = 1; % will feed from loop later

% Path to the folder containing the current subject's data
data_path  = [home_path];
disp([data_path subject_list{s} '.vhdr']);

%% Import data and save as set

if run_gui == true
    eeglab;
end

% import raw data
EEG = pop_loadbv([data_path], [subject_list{s} '.vhdr']);
EEG.setname = subject_list{s};

% Channel locations
EEG = pop_chanedit(EEG,'lookup', montage);

% save file
EEG = saveMyEEG(EEG, 'chan');

if run_gui == true
    eeglab redraw;
    erplab redraw;
end

%% Re-reference to .5 LM and create some new channels
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

% save file
EEG = saveMyEEG(EEG, 'chanOps');

if run_gui == true
    eeglab redraw;
    erplab redraw;
end

%% Frequency spectrum and (maybe) filtering
EEG = pop_fourieeg( EEG,  1:28, [] , 'chanArray',  1:28, 'EndFrequency',  150, 'IncludeLegend',  1, 'NumberOfPointsFFT',  512, 'StartFrequency',...
  0, 'Window', [ 0 3.8052e+06] );

% Plot raw data, pre-filtered
%pop_eegplot( EEG, 1, 1, 1);

% high pass filter to remove drift, 1hz
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);

% Plot raw data, post filter
%pop_eegplot( EEG, 1, 1, 1);

% save file
EEG = saveMyEEG(EEG, 'filt');


%% Create simple eventlist
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
 [subject_list{s} '_elist.txt'] ); 

% save file
EEG = saveMyEEG(EEG, 'elist');

if run_gui == true
    eeglab redraw;
    erplab redraw;
end

%% Binlister

%EEG = pop_loadset( 'LAT_101_chan_chanOps_elist.set' );

% BIN STRUCTURES LEGEND
% bin_structure1.txt = 12 bins; cue + target L/R/C + distr L/R/C
% bin_structure2.txt = 6 bins; cue + target C/Latt + distr C/Latt
% bin_structure3.txt = 6 bins; as 2 but only correct responses.

which_binStructure = 'bin_structure1.txt';

EEG  = pop_binlister( EEG , 'BDF', which_binStructure, 'ExportEL',...
 [subject_list{s} '_elist_binned.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput',...
 'EEG' ); 

% save file
EEG = saveMyEEG(EEG, 'bins');

if run_gui == true
    eeglab redraw;
    erplab redraw;
end

%% Epoching and baseline correction
EEG = pop_epochbin( EEG , [-200.0  800.0],  'pre');

% save file
EEG = saveMyEEG(EEG, 'epochs');

if run_gui == true
    eeglab redraw;
    erplab redraw;
end

%% ArtRej

% To reset the flags:
%EEG  = pop_resetrej( EEG , 'ArtifactFlag',  1:8, 'ResetArtifactFields', 'on', 'UserFlag',  1:8 );

%Moving Window peak-to-peak (EOG only) = FLAG 2
p2pth = 120 % Voltage threshold
EEG  = pop_artmwppth( EEG , 'Channel',  29:31, 'Flag', [ 1 2], 'Threshold',  p2pth, 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
  100 );


% Step-like (EOG only) = FLAG 3
slth = 50 % Voltage step threshold
winstep = 20 % window step size in ms
EEG  = pop_artstep( EEG , 'Channel',  29:31, 'Flag', [ 1 3], 'Threshold',  slth, 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
  winstep );

% AR Summary print and save to file
[EEG, tprej, acce, rej, histoflags ] = pop_summary_AR_eeg_detection(EEG,'none');
EEG = pop_summary_AR_eeg_detection(EEG, [subject_list{s}, '_AR_details.txt']);

% Sync markers to EEGLAB structure, doesnt always work
%EEG = pop_syncroartifacts(EEG, 3);

% save file
EEG = saveMyEEG(EEG, 'ar');

if run_gui == true
    eeglab redraw;
    erplab redraw;
end

%% Run ICA
% fastICA requires the fastica toolbox from http://research.ics.aalto.fi/ica/fastica/
% fastICA is fast, runICA is very slow (hours), other methods has not been
% explored, but the binICA should be 1.5x faster than the runICA

if runICA == true
    % EEG = pop_runica(EEG); % GUI propt for ICA
    EEG = pop_runica(EEG, 'icatype', 'fastica', 'chanind', 1:31);
    
    % 2D plot of components 1:24
    pop_topoplot(EEG,0, [1:24] ,'LAT_101_chan',[5 5] ,0,'electrodes','on');
    
    % 3D plot of components 1:24
    EEG = pop_headplot(EEG, 0, [1:24] , 'Components of dataset: LAT_101_chan', [5  5], 'setup',{'LAT_101_chan.spl' 'meshfile' 'mheadnew.mat' 'transform' [-0.35579 -6.3369 12.3705 0.053324 0.018746 -1.5526 1.0637 0.98772 0.93269] });
    EEG = eeg_checkset( EEG );
    
    % Plot component traces
    pop_eegplot( EEG, 0, 1, 1);
    
    % Save it
    EEG = saveMyEEG(EEG, 'fastICA');
    
end

%% Reject ICA artefacts

if runICA == true && rejectICA == true
    
end

%% ERP creation

if make_ERP == true
    
    % Filer 60Hz low pass
    EEG  = pop_basicfilter( EEG,  1:32 , 'Cutoff',  60, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    
    % average without rejected trials
    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    
    % save erp as file
    ERP = pop_savemyerp(ERP, 'erpname', '1', 'filename',...
        [subject_list{s}, '_filt_erp.erp'], 'Warning', 'on');
    
    
    
    % PLOT
    % [5 6] - cue + target L/R
    % [11 12]- cue - distr L/R
    plotBins = [5 6]
    
    ERP = pop_ploterps( ERP, plotBins,  15:24 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 5 2], 'ChLabel',...
        'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' }, 'LineWidth',  1, 'Maximize',...
        'on', 'Position', [ 98.6429 23.4048 106.857 31.9286], 'SEM', 'on', 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0.7,...
        'xscale', [ -200.0 450.0   -200:200:600 ], 'YDir', 'normal' );
    
    ERP = pop_ploterps( ERP, [ 5 6 11 12],  15:24 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 5 2], 'ChLabel',...
 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' },...
 'LineWidth',  1, 'Maximize', 'on', 'Position', [ 98.6429 23.4048 106.857 31.9286], 'SEM', 'on', 'Style', 'Classic', 'Tag', 'ERP_figure',...
 'Transparency',  0.8, 'xscale', [ -200.0 450.0   -200:100:400 ], 'YDir', 'normal' );
    
end