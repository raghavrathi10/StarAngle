function [outSAT,startTime] = stana_match_cal_sat(SAT,stana_exp_cfg,thisfilename_tle,stana_cfg)

    scores = zeros(length(stana_cfg.anameawiggle_sec),length(SAT));
    tleStruct = tleread(thisfilename_tle);
    all_scores = cell(1,length(stana_cfg.anameawiggle_sec));
    for widx=1:length(stana_cfg.anameawiggle_sec)
        startTime = datetime(stana_exp_cfg.tsstr) + seconds(stana_cfg.anameawiggle_sec(widx));
        stopTime = startTime + seconds(stana_exp_cfg.duration_sec);
        sc = satelliteScenario(startTime,stopTime,stana_cfg.analen_sec);
        sat = satellite(sc, thisfilename_tle);
        gs = groundStation(sc,stana_exp_cfg.lat_deg,stana_exp_cfg.lon_deg); 
        [cal_fShift,time,cal_dopplerInfo] = dopplershift(sat,gs,Frequency=stana_cfg.fc);
        cal_diff_fShift = diff(cal_fShift')';

        thistmatchingscores = zeros(length(SAT),length(sat));
        for satidx=1:length(SAT)
            thismea = SAT{satidx}.info(:,[1,3]);
            thistimestamp = thismea(:,1);
            for calsatidx=1:length(sat)
                thiscal = cal_diff_fShift(calsatidx,:);
                thiscalsamp = thiscal(thistimestamp);
                tempp = thismea(:,2)' - thiscalsamp;
                thistmatchingscores(satidx,calsatidx) = sum(tempp.*tempp);
            end
            [a,b] = min(thistmatchingscores(satidx,:));
            scores(widx,satidx) = a;
        end
        all_scores{widx} = thistmatchingscores;
    end
    allcostval = max(scores');
    [a, usewidx] = min(allcostval);
    usewiggleval = stana_cfg.anameawiggle_sec(usewidx);

    startTime = datetime(stana_exp_cfg.tsstr) + seconds(usewiggleval);
    stopTime = startTime + seconds(stana_exp_cfg.duration_sec);
    sc = satelliteScenario(startTime,stopTime,stana_cfg.analen_sec);
    sat = satellite(sc, thisfilename_tle);
    gs = groundStation(sc,stana_exp_cfg.lat_deg,stana_exp_cfg.lon_deg); 

    % [cal_delay,cal_time] = latency(sat,gs); % NOTE: can do this also
    [cal_fShift,time,cal_dopplerInfo] = dopplershift(sat,gs,Frequency=stana_cfg.fc);
    [cal_az, cal_el, cal_range] = aer(gs,sat);
    cal_diff_fShift = diff(cal_fShift')'; % also cal_dopplerInfo.DopplerRate
    cal_pos = states(sat, "CoordinateFrame","ecef");

    fprintf(1, '---------------- SAT Matching Results -------------------\n')
    for satidx=1:length(SAT)
        [a,b] = min(all_scores{usewidx}(satidx,:));
        SAT{satidx}.calmatchtimeshiftval = usewiggleval;
        SAT{satidx}.calmatchsatidx = b;
        SAT{satidx}.calmatchscore = a;
        SAT{satidx}.cal_dechirp = cal_diff_fShift(b,:);
        SAT{satidx}.cal_az = cal_az(b,:);
        SAT{satidx}.cal_el = cal_el(b,:);
        SAT{satidx}.cal_range = cal_range(b,:);
        SAT{satidx}.cal_pos = zeros(size(cal_pos,1),size(cal_pos,2)); 
        SAT{satidx}.cal_pos(:,:) = cal_pos(:,:,b);
        SAT{satidx}.name = sat(b).Name;
        SAT{satidx}.cal_rcvphasediff_rad = stana_cal_phasediff_rad([0,stana_exp_cfg.LNB_dist_m], stana_exp_cfg.LNB_az_degree*pi/180, [SAT{satidx}.cal_az;SAT{satidx}.cal_el]'*pi/180, stana_cfg.fc);
        SAT{satidx}.sat = sat(b);
        SAT{satidx}.tle = tleStruct(b);
        SAT{satidx}.nameid = erase(SAT{satidx}.name,"STARLINK-");

        fprintf(1, 'SAT %d is determined to be %s cost %.2f\n', satidx, SAT{satidx}.name, SAT{satidx}.calmatchscore);
    end
    fprintf(1, 'Adjusted time for %.2f seconds\n',usewiggleval);
    fprintf(1, '---------------------------------------------------------\n')
    
    outSAT = SAT;