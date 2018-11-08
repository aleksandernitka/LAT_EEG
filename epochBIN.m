function[] = epochBIN(preprocessList, location_path, save_path, binlisterFile, ...
    epochLen)

for s = 1:length(preprocessList)
    
    fprintf(['\n\n Processing ', preprocessList{s}, '\n\n']);
    
    %Load the EEG
    EEG = pop_loadset([preprocessList{s} '_PrePro.set'], location_path);
    
    %% EventList, Binlister & Epoch
    
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on',...
        'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        [save_path  preprocessList{s} '_elist.txt']);
    
    % Binlister
    EEG  = pop_binlister( EEG , 'BDF', binlisterFile, 'ExportEL',...
        [save_path preprocessList{s} '_elist_binned.txt'], ...
        'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput',...
        'EEG' );
    
    % Epoching and base correction
    EEG = pop_epochbin( EEG , epochLen,  'pre');
    
    % Save data
    EEG = saveMyEEG(EEG, 'Binned', save_path);
    
end
end

