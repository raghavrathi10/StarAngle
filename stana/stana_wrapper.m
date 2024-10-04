if 1
    stana_gen_exp_info;
    stana_USE_WRAPPER = 1;
    stana_wrapper_cfg.LOAD_SAVED_RES = 0;
    stana_wrapper_cfg.DO_GEN_EXP_TLE_FILE = 0;
    stana_wrapper_cfg.GEN_SIG = 1;
    stana_wrapper_cfg.DO_INIT_SCAN = 1;
    stana_wrapper_cfg.DO_SAT_LM = 1;  
    stana_wrapper_cfg.DO_TWO_ANT_CFO_CAL = 1;
    stana_wrapper_cfg.DO_PHASE_CAL = 1;

    plot_mainres = [];
    plot_phasemea = [];
    plot_consistent = [];
    
    for stana_wrapper_exp_loc_idx=1:length(stana_exp_info)
        for stana_wrapper_exp_angle_idx=1:length(stana_exp_info{stana_wrapper_exp_loc_idx}.angles)
            thisangleres = [];
            for stana_wrapper_exp_run_idx=1:length(stana_exp_info{stana_wrapper_exp_loc_idx}.angles{stana_wrapper_exp_angle_idx}.filelist)
                stana_wrapper_cfg.thisfilename = stana_exp_info{stana_wrapper_exp_loc_idx}.angles{stana_wrapper_exp_angle_idx}.filelist{stana_wrapper_exp_run_idx};
                stana_process;
                save(thisfilename_foundbeacons, 'foundbeacons', 'phasediffres', 'ANTCFO', 'ANT_DopplerRate_Hz_sec', 'EST_NOISE_POWER', 'SAT', 'RES_usaz', 'stana_exp_cfg');
                
                thisres = [stana_exp_info{stana_wrapper_exp_loc_idx}.angles{stana_wrapper_exp_angle_idx}.angleval_deg, RES_usaz.estval];

                thispairsnr = [];
                thispointcount = [];
                for checksatpairidx=1:length(phasediffres)
                    thissnr = [];
                    for satidx=1:2
                        for STANA_ant_idx=1:2
                            estsnr = power(phasediffres{checksatpairidx}.usesigmag{satidx}(:,STANA_ant_idx),2)/EST_NOISE_POWER(STANA_ant_idx);
                            % some of them will be 0, skip
                            tempp = find(estsnr);
                            estsnr = estsnr(tempp);
                            thissnr = [thissnr, mean(estsnr)];
                        end
                    end
                    thispairsnr = [thispairsnr, min(thissnr)]; 
                    thispointcount = [thispointcount, length(phasediffres{checksatpairidx}.vsavg)];
                end
                
                smatchingcostavg = zeros(1,length(SAT));
                for sidx=1:length(SAT)
                    thisnum = size(SAT{sidx}.info,1);
                    thiscost = SAT{sidx}.calmatchscore;
                    smatchingcostavg(sidx) = thiscost/thisnum;
                end

                thisres = [thisres, 10*log10(max(thispairsnr)), sum(thispointcount), length(phasediffres), sqrt(mean(smatchingcostavg)), thisres(2), 0];
                
                plot_mainres = [plot_mainres; thisres];
                thisangleres = [thisangleres; thisres];

                for checksatpairidx=1:length(phasediffres)
                    meavals = unwrap(phasediffres{checksatpairidx}.vsavg)*180/pi;
                    plottry = RES_usaz.opdiff(phasediffres{checksatpairidx}.vsidx,checksatpairidx);
                    plotadd = [-2:2]*2*pi; plotscore = zeros(1,length(plotadd));
                    for h=1:length(plotscore)
                        tempp = plottry + plotadd(h);
                        tempp1 = tempp' - unwrap(phasediffres{checksatpairidx}.vsavg);
                        plotscore(h) = sum(tempp1.*tempp1);
                    end
                    [a,b] = min(plotscore);
                    calvals = (plottry + plotadd(b))*180/pi;
                    thisres = [calvals';meavals]';
                    plot_phasemea = [plot_phasemea; thisres];
                end   

            end  
            herenumruns = length(stana_exp_info{stana_wrapper_exp_loc_idx}.angles{stana_wrapper_exp_angle_idx}.filelist);
            thisbgn = size(plot_mainres,1)-herenumruns+1;
            plot_mainres(thisbgn:end,7) = mean(plot_mainres(thisbgn:end,7));
            tempp = abs(plot_mainres(thisbgn:end,2) - plot_mainres(thisbgn:end,1));
            if length(find(tempp > 30)) == 0
                plot_mainres(thisbgn:end,8) = herenumruns;
            end
            plot_consistent = [plot_consistent, std(thisangleres(:,2))];

        end
    end
    tempp = find(abs(plot_mainres(:,1)-plot_mainres(:,2)) < 30);
    plot_mainres_no_failure = plot_mainres(tempp,:);
    tempp = find(plot_mainres_no_failure(:,8)>=3);
    plot_mainres_3runs = plot_mainres_no_failure(tempp,:);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% close all

STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG = 0;
STANA_WRAPPER_SAVE_FIG_FLAG = 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG;
STANA_WRAPPER_SAVE_FIG_dir = './';

myfontsize = 18;
if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_scatterest.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    scatter(plot_mainres(:,1),plot_mainres(:,2))
    xlabel('Actual (deg)')
    ylabel('Estimated (deg)')
    titlestr = sprintf('Estimation of User Orientation');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    alldegval = RES_usaz.LNB_az_degree_vals;
    xlim([min(alldegval) max(alldegval)])
    ylim([min(alldegval) max(alldegval)])
    hold on
    plot(alldegval,alldegval,'--')
    hold off
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 1 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_esterr.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    p1 = cdfplot(abs(plot_mainres_no_failure(:,2)-plot_mainres_no_failure(:,1)));
    set(p1, 'LineStyle', '-', 'LineWidth', 2);
    xlabel('Estimation Error (deg)')
    ylabel('Fraction')
    titlestr = sprintf('Estimation Error of User Orientation');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    % xlim([0 30])
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_scatterphasemea.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    scatter(plot_phasemea(:,1),plot_phasemea(:,2))
    xlabel('Calculated (deg)')
    ylabel('Measured (deg)')
    titlestr = sprintf('Phase Measurement and Calculation');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    alldegval = [-400:400];
    xlim([min(alldegval) max(alldegval)])
    ylim([min(alldegval) max(alldegval)])
    hold on
    plot(alldegval,alldegval,'--')
    hold off
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end    
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_phasemeaerr.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    p1 = cdfplot(abs(plot_phasemea(:,2)-plot_phasemea(:,1)));
    set(p1, 'LineStyle', '-', 'LineWidth', 2);
    xlabel('Measurement Error (deg)')
    ylabel('Fraction')
    titlestr = sprintf('Phase Measurement Error');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    xlim([0 50])
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/show_snr.fig',STANA_WRAPPER_SAVE_FIG_dir);    
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    p1 = cdfplot(plot_mainres(:,3));
    set(p1, 'LineStyle', '-', 'LineWidth', 2);
    xlabel('SNR (dB)')
    ylabel('Fraction')
    titlestr = sprintf('SNR');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    % xlim([0 30])
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/show_satpair.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    p1 = cdfplot(plot_mainres(:,5));
    set(p1, 'LineStyle', '-', 'LineWidth', 2);
    xlabel('Number of Pairs')
    ylabel('Fraction')
    titlestr = sprintf('Satellite Pairs');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    % xlim([0 30])
    if 1
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/show_phasemea.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    p1 = cdfplot(plot_mainres(:,4));
    set(p1, 'LineStyle', '-', 'LineWidth', 2);
    xlabel('Number of Measurements')
    ylabel('Fraction')
    titlestr = sprintf('Phase Measurements');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    % xlim([0 30])
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end



if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_err_snr.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);

    plot_x_0 = plot_mainres_no_failure(:,3);
    plot_y_0 = abs(plot_mainres_no_failure(:,2)-plot_mainres_no_failure(:,1));
    plot_bins = [
        -100,-34;
        -34,-33;
        -33,-32;
        -32,100;
        ];
    plot_y_1 = zeros(size(plot_bins,1),2);
    plot_y_2 = zeros(1,size(plot_bins,1));
    for h=1:size(plot_bins,1)
        tempp = find(plot_x_0 >= plot_bins(h,1) & plot_x_0 <= plot_bins(h,2));
        plot_y_1(h,:) = [sum(plot_y_0(tempp)) length(tempp)];
        plot_y_2(h) = median(plot_y_0(tempp));
    end
    plot_y = plot_y_1(:,1)./plot_y_1(:,2);
    plot_y = plot_y_2;

    bar(plot_y)
    plot_bin_label = cell(1,size(plot_bins,1));
    for h=1:size(plot_bins,1)
        if h==1
            plot_bin_label{h} = sprintf('$<$ %d', plot_bins(h,2));
        elseif h==size(plot_bins,1)
            plot_bin_label{h} = sprintf('$\\ge$ %d', plot_bins(h,1));
        else
            plot_bin_label{h} = sprintf('[%d,%d)', plot_bins(h,1),plot_bins(h,2));
        end
    end

    set(gca, 'XTickLabel',plot_bin_label, 'XTick',1:numel(plot_bin_label))   
    xaxisproperties= get(gca, 'XAxis');
    xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
    ylim([0 10])

    xlabel('SNR (dB)')
    ylabel('Median Error (deg)')
    titlestr = sprintf('Error vs. SNR');
    title(titlestr)
    set(gca,'FontSize',myfontsize)
    grid on
    % xlim([0 30])
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_err_numsatpair.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    plot_x_0 = plot_mainres_no_failure(:,5);
    plot_y_0 = abs(plot_mainres_no_failure(:,2)-plot_mainres_no_failure(:,1));
    
        plot_bins = [
            1,1;
            2,3;
            4,100;
            ];
        plot_y_1 = zeros(size(plot_bins,1),2);
        plot_y_2 = zeros(1,size(plot_bins,1));
        for h=1:size(plot_bins,1)
            tempp = find(plot_x_0 >= plot_bins(h,1) & plot_x_0 <= plot_bins(h,2));
            plot_y_1(h,:) = [sum(plot_y_0(tempp)) length(tempp)];
            plot_y_2(h) = median(plot_y_0(tempp));
        end
        plot_y = plot_y_1(:,1)./plot_y_1(:,2);
        plot_y = plot_y_2;

        bar(plot_y)
        plot_bin_label = cell(1,size(plot_bins,1));
        plot_bin_label = cell(1,size(plot_bins,1));
        for h=1:size(plot_bins,1)
            if h==size(plot_bins,1)
                plot_bin_label{h} = sprintf('$\\ge$ %d', plot_bins(h,1));
            else
                if plot_bins(h,1) == plot_bins(h,2)
                    plot_bin_label{h} = sprintf('%d', plot_bins(h,1));
                else
                    plot_bin_label{h} = sprintf('[%d,%d]', plot_bins(h,1),plot_bins(h,2));
                end
            end
        end
        
        set(gca, 'XTickLabel',plot_bin_label, 'XTick',1:numel(plot_bin_label))   
        xaxisproperties= get(gca, 'XAxis');
        xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
        ylim([0 10])

    xlabel('Number of Satellite Pairs')
    ylabel('Median Error (deg)')
    titlestr = sprintf('Error vs. Number of Satellite Pairs');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    % xlim([0 30])
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_err_nummea.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    plot_x_0 = plot_mainres_no_failure(:,4);
    plot_y_0 = abs(plot_mainres_no_failure(:,2)-plot_mainres_no_failure(:,1));
    plot_bins = [
        0,10;
        11,20;
        21,40;
        41,100;
        ];
    plot_y_1 = zeros(size(plot_bins,1),2);
    plot_y_2 = zeros(1,size(plot_bins,1));
    for h=1:size(plot_bins,1)
        tempp = find(plot_x_0 >= plot_bins(h,1) & plot_x_0 <= plot_bins(h,2));
        plot_y_1(h,:) = [sum(plot_y_0(tempp)) length(tempp)];
        plot_y_2(h) = median(plot_y_0(tempp));
    end
    plot_y = plot_y_1(:,1)./plot_y_1(:,2);
    plot_y = plot_y_2;

    bar(plot_y)
    plot_bin_label = cell(1,size(plot_bins,1));
    for h=1:size(plot_bins,1)
        if h==1
            plot_bin_label{h} = sprintf('$\\le$ %d', plot_bins(h,2));
        elseif h==size(plot_bins,1)
            plot_bin_label{h} = sprintf('$\\ge$ %d', plot_bins(h,1));
        else
            plot_bin_label{h} = sprintf('[%d,%d]', plot_bins(h,1),plot_bins(h,2));
        end
    end
    set(gca, 'XTickLabel',plot_bin_label, 'XTick',1:numel(plot_bin_label))   
    xaxisproperties= get(gca, 'XAxis');
    xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
    ylim([0 10])

    xlabel('Number of Measurements')
    ylabel('Median Error (deg)')
    titlestr = sprintf('Error vs. Number of Measurements');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    grid on
    % xlim([0 30])
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

if 0 || STANA_WRAPPER_MASS_GEN_ALL_FIG_FLAG
    thisfigname = sprintf('%s/res_consistency.fig',STANA_WRAPPER_SAVE_FIG_dir);
    thispngname = thisfigname; thispngname(end-2:end) = 'png';
    openfig(thisfigname);
    res1 = abs(plot_mainres_no_failure(:,2)-plot_mainres_no_failure(:,1));
    res2 = abs(plot_mainres_3runs(:,2)-plot_mainres_3runs(:,7));
    fprintf(1, 'median error: vs. ground truth %f, vs. self average %f\n', median(res1), median(res2));
    p1 = cdfplot(res1);
    hold on
    p2 = cdfplot(res2);
    set(p1, 'LineStyle', '-', 'LineWidth', 2);
    set(p2, 'LineStyle', '--', 'LineWidth', 2);
    xlabel('Estimation Error (deg)')
    ylabel('Fraction')
    titlestr = sprintf('Estimation Error of User Orientation');
    title(titlestr)
    set(gca,'FontSize',myfontsize);
    legend('vs. ground truth', 'vs. self average', 'Location','southeast')
    grid on
    % xlim([0 30])
    hold off
    if STANA_WRAPPER_SAVE_FIG_FLAG
        saveas(gcf,thisfigname);
        saveas(gcf,thispngname);
    end
end

