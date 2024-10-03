if stana_USE_WRAPPER == 0
    STANA_LOAD_SAVED_RES      = 0;
    STANA_DO_GEN_EXP_TLE_FILE = 0;
    STANA_GEN_SIG             = 1;
    STANA_DO_INIT_SCAN        = 1;
    STANA_DO_SAT_LM           = 1;
    STANA_DO_TWO_ANT_CFO_CAL  = 1;
    STANA_DO_PHASE_CAL        = 1;
else
    STANA_DO_GEN_EXP_TLE_FILE = stana_wrapper_cfg.DO_GEN_EXP_TLE_FILE;
    STANA_GEN_SIG = stana_wrapper_cfg.GEN_SIG;
    STANA_DO_INIT_SCAN = stana_wrapper_cfg.DO_INIT_SCAN;
    STANA_DO_SAT_LM = stana_wrapper_cfg.DO_SAT_LM;
    STANA_DO_TWO_ANT_CFO_CAL = stana_wrapper_cfg.DO_TWO_ANT_CFO_CAL;
    STANA_DO_PHASE_CAL = stana_wrapper_cfg.DO_PHASE_CAL;
    STANA_LOAD_SAVED_RES = stana_wrapper_cfg.LOAD_SAVED_RES;
end

STANA_DO_PHASE_COMP           = 1;

STANA_ant_num = 2;
% -------------------------------------------------------------------------
% usrp_sig_data_type = 'float';
usrp_sig_data_type = 'int16';

if stana_USE_WRAPPER == 0
    thisfilename = '../AEexpdata/06-16/sig1_ant1'; 
    thisfilename = '../tempp/sig1_ant1'; 
else
    thisfilename = stana_wrapper_cfg.thisfilename;
end

thisfilename_tle = thisfilename;
thisfilename_tle(end-4:end) = [];
thisfilename_tle = [thisfilename_tle, '.tle'];

thisfilename_foundbeacons = thisfilename;
thisfilename_foundbeacons(end-3:end) = [];
thisfilename_foundbeacons = [thisfilename_foundbeacons, 'foundbeacons.mat'] ;   

alltelfilename = thisfilename;
tempp = find(alltelfilename == '/');
alltelfilename(tempp(end)+1:end) = [];
alltelfilename = [alltelfilename, 'All_sat.tle'];

thisfilename_cfg = thisfilename_tle;
thisfilename_cfg(end-2:end) = 'cfg';

if isfile(thisfilename_cfg)
    stana_exp_cfg = stana_read_exp_cfg(thisfilename_cfg);    
else
    fprintf(1, 'ERROR -- no cfg file!\n')
end

if STANA_DO_GEN_EXP_TLE_FILE
    fprintf('Finding flyover satellites for experiment %s\n', thisfilename);
    SatIDs = stana_find_flyover_sats(stana_exp_cfg,alltelfilename);
    stana_GenTle(string(SatIDs), alltelfilename, thisfilename_tle);    
end

if isfile(thisfilename_tle) 
else
    fprintf(1, 'ERROR -- no tle file!\n')
end

% save(thisfilename_foundbeacons, 'foundbeacons', 'phasediffres', 'ANTCFO', 'ANT_DopplerRate_Hz_sec', 'EST_NOISE_POWER', 'SAT', 'RES_usaz', 'stana_exp_cfg');
if STANA_LOAD_SAVED_RES
    if isfile(thisfilename_foundbeacons)
        load(thisfilename_foundbeacons); 
    else
        fprintf(1, 'ERROR -- want to use saved results but has no saved data!\n')
    end
end

fprintf(1, 'processing signal from %s\n', thisfilename)
% -------------------------------------------------------------------------

if STANA_GEN_SIG == 1
    fprintf(1, 'reading files\n')
    thisfile = fopen(thisfilename); A = fread(thisfile, usrp_sig_data_type); fclose(thisfile); B = A(1:2:end) + i*A(2:2:end); A=[]; B=transpose(B); 
    starlink_time_sig = B; clear B;
    EST_NOISE_POWER = mean(abs(starlink_time_sig));

    if STANA_ant_num == 2
        thisfilename_2 = thisfilename;
        thisfilename_2(end) = '2';
        thisfile = fopen(thisfilename_2); A = fread(thisfile, usrp_sig_data_type); fclose(thisfile); B = A(1:2:end) + i*A(2:2:end); A=[]; B=transpose(B); 
        starlink_time_sig_2 = B; clear B;
        EST_NOISE_POWER = [EST_NOISE_POWER, mean(abs(starlink_time_sig_2))];
    end
    EST_NOISE_POWER = EST_NOISE_POWER.*EST_NOISE_POWER;
end

% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% NOTE: Scanning for beacons second by second. Grouping beacons belonging 
% to the same satellite. Finding chirp rate 
% Input: starlink_time_sig, stana_cfg
% Output: foundbeacon

if STANA_DO_INIT_SCAN 
    foundbeacons = stana_detect_sats(starlink_time_sig,stana_cfg);
end
checkmergesegnum = length(foundbeacons);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Linking clusters from second to second

if STANA_DO_SAT_LM
    [SAT,dbg_info_SAT] = stana_link_sats(foundbeacons,stana_cfg);
    
    if isfile(thisfilename_tle) == 0 || isfile(thisfilename_cfg) == 0
    else
        [SAT, adjStatTime] = stana_match_cal_sat(SAT,stana_exp_cfg,thisfilename_tle,stana_cfg);
    end
end

if stana_USE_WRAPPER == 0
    figure;
    stana_plot_found_sat;
end

% -------------------------------------------------------------------------
    
if STANA_DO_TWO_ANT_CFO_CAL && STANA_ant_num == 2
    [ANTCFO, ANT_DopplerRate_Hz_sec] = stana_cal_ant_cfo(checkmergesegnum,SAT,starlink_time_sig,starlink_time_sig_2,stana_cfg);
end

if STANA_DO_PHASE_COMP
    alltocheckclutsers = stana_sel_pairs(SAT);
    if STANA_DO_PHASE_CAL
        phasediffres = stana_measure_phase_diff(alltocheckclutsers,STANA_ant_num,checkmergesegnum,ANTCFO,ANT_DopplerRate_Hz_sec,SAT,starlink_time_sig,starlink_time_sig_2,stana_cfg);
    end
    RES_usaz = stana_est_user_az(alltocheckclutsers,checkmergesegnum,stana_exp_cfg.LNB_dist_m,SAT,phasediffres, stana_cfg.fc); 
    fprintf(1, 'best matching user az angle: %.2f (deg); cost: %.2f; actual angle: %.2f (deg); error: %.2f (deg)\n', RES_usaz.estval,RES_usaz.estcost,stana_exp_cfg.LNB_az_degree,RES_usaz.estval-stana_exp_cfg.LNB_az_degree)    
    if stana_USE_WRAPPER == 0
        figure;
        stana_plot_phase;
        figure;
        stana_plot_cost;
    end
end