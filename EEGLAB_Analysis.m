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
importList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};

% RUN the import module
ImportVHDR2SET(importList, raw_data_path, processed_data_path);


%% Pre-processing for each subject

% Run only below subjects
preprocessList = {};


% RUN the preprocessing module
PreProcessEEG(preprocessList, processed_data_path, processed_data_path, true);

%% ICA
method = 'fastica';
processList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
extension = '_PrePro';

run_ica(processList, processed_data_path, processed_data_path, method,...
    extension, false);

%% Epoching and BDF

preprocessList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
% Specify epoch duration
epochLen = [-200 600];
% Selecte Bin lister file
binlisterFile = 'bin_structure1.txt';


epochBIN(preprocessList, processed_data_path, processed_data_path, binlisterFile, ...
    epochLen);

%% Artifact Rejection

% args:
% arProcessList - list of subjects to process
% expName - what file name to expect, eg: '_Binned_ar.set'
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
% syncEEGLAB - synchronise EVENTLIST and EEG.reject so markers tally up
%   use 'bi' for cross reference or 'push' for ERPLAB -> EEGLAB or 'none'
%   to skip this step.

% RUN peak-to-peak,
% more here: https://github.com/lucklab/erplab/wiki/Artifact-Detection-in-Epoched-Data
arProcessList = {'LAT_3'};
chans = [29:32];
flagAs = 2;
trialWin = [-200 600];
windowSize = 200;
windowStep = 50;
threshold = {100};

% values:
% 1 - 100, 2 - 80, 3 - 100, 4 - 80, 5 - 80, 6 - 60

EEG = ArtRej(arProcessList, ...
    '_PrePro_Binned',...
    processed_data_path, ...
    true, ...
    processed_data_path,...
    'p2p', ...
    true, ...
    flagAs, ...
    chans, ...
    trialWin, ...
    windowSize, ...
    threshold, ...
    windowStep,...
    1);


% STEP like
arProcessList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
chans = [29:32];
flagAs = 3;
trialWin = [-200 600];
windowSize = 200;
windowStep = 50;
threshold = {30, 30, 40, 30, 30, 30};

% values:
% 1 - 100, 2 - 100, 3 - 100, 4 - 80, 5 - 80, 6 - 60

EEG = ArtRej(arProcessList, ...
    '_PrePro_Binned_ar',...
    processed_data_path, ...
    true, ...
    processed_data_path,...
    'step', ...
    false, ...
    flagAs, ...
    chans, ...
    trialWin, ...
    windowSize, ...
    threshold, ...
    windowStep,...
    false);

%% Make subject-level ERPs

% args:
% erpProcessList - subjects to process 
% location_path - where the set files are
% save_path - where to save the ERPs
% save1 - whether to save the ERP at this stage
% createIpsiContra - whether to create ipsi/contra bins
% rmBaseline - baseline correction (yes/no) 
% lowPass - low pass filter (smoothing) (yes/no)
% save2 - whether to save at this stage
% plotERP - plot individual ERP lines
% plots_data_path - where to save the pdfs
% plotSingleTrials - plot single trials
% electSingleTrials - what electrodes to plot single trails for

erpProcessList = {'LAT_1', 'LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};

subjectLevelERP(erpProcessList,...
    processed_data_path, ...
    processed_data_path, ...
    true, ... % save1 - whether to save the ERP at this stage
    true, ... % createIpsiContra - whether to create ipsi/contra bins
    true, ... % rmBaseline - baseline correction (yes/no)
    true, ... % lowPass - low pass filter (smoothing) (yes/no)
    true, ... % save2 - whether to save at this stage
    true, ... % plotERP - plot individual ERP lines
    plots_data_path, ...
    true); % electSingleTrials - what electrodes to plot single trails for




%% GRAND MEANS

% args:
% ssList - filename where all id ERPs are listed
% save_path - where to save the grad erp
% plotERP - create grand erp plot
% plotDiff - create grand erp plot difference ipsi-contra
% plots_save_path - where to save the pdfs

ssList = 'grandMeanList.txt';

GrandERP(ssList, processed_data_path, true, true, plots_data_path);
