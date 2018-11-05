function[EEG] = ImportVHDR2SET(importList, location_path, save_path)

for s = 1:length(importList)
    
    % import raw data
    EEG = pop_loadbv(location_path, [importList{s} '.vhdr']);
    EEG.setname = importList{s};
    
    % save file
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', save_path);
    fprintf(['\nSaved ', EEG.setname, '.set\n']);
end

end