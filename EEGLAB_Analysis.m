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
arProcessList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
chans = [29:32];
flagAs = 2;
trialWin = [-200 780];
windowSize = 200;
windowStep = 50;
threshold = {100, 100, 100, 100, 100, 100};

EEG = ArtRej(arProcessList, ...
    '_Binned',...
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
    false);

% Peak-to-peak on frontal electrodes
arProcessList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
chans = [1 2];
flagAs = 3;
trialWin = [-200 780];
windowSize = 200;
windowStep = 100;
threshold = {105, 100, 100, 100, 100, 100};

EEG = ArtRej(arProcessList, ...
    '_Binned_ar',...
    processed_data_path, ...
    true, ...
    processed_data_path,...
    'p2p', ...
    false, ...
    flagAs, ...
    chans, ...
    trialWin, ...
    windowSize, ...
    threshold, ...
    windowStep,...
    false);

% Peak-to-peak on midline electrodes
arProcessList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
chans = [25 26 27 28];
flagAs = 4;
trialWin = [-200 780];
windowSize = 200;
windowStep = 100;
threshold = {100, 100, 100, 100, 100, 100};

EEG = ArtRej(arProcessList, ...
    '_Binned_ar',...
    processed_data_path, ...
    true, ...
    processed_data_path,...
    'p2p', ...
    false, ...
    flagAs, ...
    chans, ...
    trialWin, ...
    windowSize, ...
    threshold, ...
    windowStep,...
    false);

% RUN step-like

% arProcessList = {'LAT_1'};
% chans = [29:32];
% flagAs = 3;
% trialWin = [-200 780];
% windowSize = 400;
% windowStep = 10;
% threshold = {30, 15, 15, 15, 15, 15};
% 
% EEG = ArtRej(arProcessList, ...
%     '_Binned_ar',...
%     processed_data_path, ...
%     true, ...
%     processed_data_path,...
%     'step', ...
%     false, ...
%     flagAs, ...
%     chans, ...
%     trialWin, ...
%     windowSize, ...
%     threshold, ...
%     windowStep,...
%     true,...
%     'bi');

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

erpProcessList = {'LAT_1','LAT_2', 'LAT_3', 'LAT_4', 'LAT_5', 'LAT_6'};
electSingleTrials = {};

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