clear all; 
close all; 
clc;

os = 'mac';
run_gui = false; % will open the gui and redraw after each step

eeglab; % helps with loading files from BV
%% Setup file locations
subject_list = {'LAT_101'};
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
  'nch31 = ch31 - ( ch32 *.5 ) Label VEOG',  'nch32 = ch32 - ( ch32 *.5 ) Label LM' ...
  'nch33 = (ch21 + ch19 + ch23)/3 Label OAVG1', 'nch34 = (ch22 + ch20 + ch24)/3 Label OAVG2'} , 'ErrorMsg', 'popup', 'Warning',...
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

which_binStructure = 'bin_structure2.txt';

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

%Moving Window peak-to-peak (EOG only) = FLAG 2
p2pth = 100 % Voltage threshold
EEG  = pop_artmwppth( EEG , 'Channel',  29:31, 'Flag', [ 1 2], 'Threshold',  p2pth, 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
  100 );


% Step-like (EOG only) = FLAG 3
slth = 15 % Voltage step threshold
winstep = 20 % window step size in ms
EEG  = pop_artstep( EEG , 'Channel',  29:31, 'Flag', [ 1 3], 'Threshold',  slth, 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',...
  winstep );

% AR Summary print and save to file
[EEG, tprej, acce, rej, histoflags ] = pop_summary_AR_eeg_detection(EEG,'none');
EEG = pop_summary_AR_eeg_detection(EEG, [subject_list{s}, '_AR_details.txt']);

% Sync markers
%EEG = pop_syncroartifacts(EEG, 3);

% save file
EEG = saveMyEEG(EEG, 'ar');

if run_gui == true
    eeglab redraw;
    erplab redraw;
end


%% ERP creation

% ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
% 
% % Save ERP
% ERP = pop_savemyerp(ERP, 'erpname', 'erp_101', 'filename',...
% [ 'erp_', subject_list{s}, '.erp'], 'filepath', 'C:\Users\aln318\Documents\MATLAB', 'Warning', 'on');
% 
% ERP = pop_averager( EEG , 'Compute', 'EFFT', 'Criterion',...
%  'good', 'ExcludeBoundary', 'on', 'SEM', 'on', 'TaperWindow', {'hanning' [ -200 798]} );