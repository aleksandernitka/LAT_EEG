function[EEG] = saveMyEEG(EEG, suffix, data_path)

EEG = eeg_checkset( EEG );

% check if name has an underscore
if suffix(1) ~= '_'
    suffix = ['_', suffix];
end

% check if suffix was already added
if (contains(EEG.setname, suffix))
    % don't change the setname
else
    EEG.setname = [EEG.setname, suffix];
end


% if no path specified save into the wd
if nargin == 2
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set']);
else
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);
end

fprintf('\n******\nSaved file as %s\n******\n\n', EEG.setname);


end