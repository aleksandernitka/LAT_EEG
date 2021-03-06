function[] = PreProcessEEG(preprocessList, location_path, save_path, resample)

for s = 1:length(preprocessList)
    
    fprintf(['\n\n Processing ', preprocessList{s}, '\n\n']);
    
    %Load the EEG
    EEG = pop_loadset([preprocessList{s} '.set'], location_path);
    
    %% Pre-Process
    
    if (resample)
        % Downsample
        EEG = pop_resample( EEG, 250);
        EEG.setname = preprocessList{s};
    end
        
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
    % Modified CAML cap includes locations for LHEOG and RHEOG
    %EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    EEG = pop_chanedit(EEG, 'lookup','CAML_locs.ced');
    
    % Save file
    EEG = saveMyEEG(EEG, 'PrePro', save_path);
    
end



end