function[] = ArtRej(arProcessList, location_path, save, save_path,...
    method, resetFlags, flagId, channels, Twindow, windowSize, threshold,...
    plotRaw)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A simple function that wraps around EEG/ERP LAB
% takes specified files and runs them through a sepcified AR method -
% ONE AT A TIME.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for s = 1:length(arProcessList)
    
    fprintf(['\n\n Running AR on ', arProcessList{s}, '\n\n']);
    
    % Load EEG
    EEG = pop_loadset([arProcessList{s} '_Binned.set'], location_path);
    
    % Reset Flags is required
    if (resetFlags)
        EEG  = pop_resetrej( EEG , 'ArtifactFlag',  1:8,...
            'ResetArtifactFields', 'on', 'UserFlag',  1:8 );
    end
    
    % Run AR using peak-to-peak method
    if (method == 'p2p')
        
        thisThreshold = threshold{s};
        thisWindowSize = windowSize{s};
        
        EEG  = pop_artmwppth( EEG ,...
            'Channel',  channels,...
            'Flag', [ 1 flagId],...
            'Threshold',  thisThreshold,...
            'Twindow', Twindow,...
            'Windowsize',  thisWindowSize,...
            'Windowstep', 100 );
    
    elseif (method == 'step')
        
        thisThreshold = threshold{s};
        thisWindowSize = windowSize{s};
        
        EEG  = pop_artstep( EEG,...
            'Channel',  29:31,...
            'Flag', [ 1 3],...
            'Threshold', thisThreshold,...
            'Twindow', Twindow,...
            'Windowsize',  200,...
            'Windowstep', thisWindowSize);
        
    else
        fprintf('AR method not selected, quitting...');
        break
    end
    
    % Plot signal
    if (plotRaw)
        pop_eegplot( EEG, 1, 1, 1);
        fprintf(['\n\n Displaying raw data and AR markers for ',...
            arProcessList{s}, '\n\n PRESS ANY KEY TO CONTINUTE...\n\n']);
        pause;
        fprintf('\n\nResuming...\n\n');
    end
    
    
    % Print Summary of AR
    [EEG, tprej, acce, rej, histoflags ] = pop_summary_AR_eeg_detection(EEG,'none');
    
    % Save file and output
    % Save only after all AR methods required have been applied
    if (save)
        
        EEG = saveMyEEG(EEG, 'ar', save_path);
        EEG = pop_summary_AR_eeg_detection(EEG, [save_path arProcessList{s}, '_AR_details.txt']);
        
    end
    
end

end