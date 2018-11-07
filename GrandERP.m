function[] = GrandERP(ssList, save_path, plotERP, plotDiff, plots_save_path)

%Construct mean ERP, see grandMeanList.txt for list of ERP sets used
ERP = pop_gaverager( ssList , 'ExcludeNullBin', 'on', 'SEM', 'on' );

ERP = pop_savemyerp(ERP, ...
    'erpname', 'meanERP', ...
    'filename', 'LAT_meanERP.erp',...
    'filepath', save_path,...
    'Warning', 'off');


% ERP plots
if (plotERP)
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
        plotMyERP(ERP, Bins2Plot{s}, false, true, plots_save_path);
        ERP.erpname = 'meanERP';
    end
    
end

%DIFF plots

if (plotDiff)
    Bins2Plot = {[13 14], [15 16], [17 18]};
    Names2Plot = {...
        'MeanERP_NEUTRAL_Diff',...
        'MeanERP_POSITIVE_Diff',...
        'MeanERP_NEGATIVE_Diff'};
    
    for s = 1:length(Bins2Plot)
        ERP.erpname = Names2Plot{s};
        plotMyERP(ERP, Bins2Plot{s}, false, true, plots_save_path);
        ERP.erpname = 'meanERP';
    end
    
end
end
