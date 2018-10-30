function[ERP] = plotMyERP(ERP, ERPname, bins, hold, save, processed_data_path)

ERP = pop_ploterps( ERP, bins,  15:2:23 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 6 1], 'ChLabel',...
    'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' }, 'LineWidth',  1,...
    'Maximize', 'on', 'Position', [ 98.625 23.3889 106.875 31.9444], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',...
    [ -100.0 600.0   -200:200:600 ], 'YDir', 'normal' );


ERP.erpname = ['ERP_' ERPname]

if save == true
    if nargin < 6
        
        ERP = pop_exporterplabfigure( ERP, 'Format', 'pdf', 'Resolution',  300,...
            'SaveMode', 'auto', 'Tag', {'ERP_figure'} );
    else
        
        ERP = pop_exporterplabfigure( ERP, 'Filepath', processed_data_path ,'Format', 'pdf', 'Resolution',  300,...
            'SaveMode', 'auto', 'Tag', {'ERP_figure'} );
    end
    
end

if hold ~= true
    close all;
end


end