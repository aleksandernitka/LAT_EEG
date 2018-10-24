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