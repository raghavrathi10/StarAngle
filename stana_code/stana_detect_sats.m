function foundbeacons = stana_detect_sats(starlink_time_sig,stana_cfg)

segnum = floor(length(starlink_time_sig)/stana_cfg.seglen_sampnum);
usesiglen = segnum*stana_cfg.seglen_sampnum;
seglen_base_freq_Hz = 1/stana_cfg.seglen_sec;
checkmergesegnum = floor(segnum/stana_cfg.mergesegnum);

usesig = starlink_time_sig(1:usesiglen);
usesig = usesig - mean(usesig);
matsig = transpose(reshape(usesig, stana_cfg.seglen_sampnum, segnum));
fft_matsig = fft(matsig, [], 2);

foundbeacons = cell(1,checkmergesegnum);
for checkidx=1:checkmergesegnum
    fprintf(1, 'checking siganl at %d sec\n', checkidx)
    tbgn = (checkidx-1)*stana_cfg.mergesegnum + 1;
    tend = tbgn + stana_cfg.mergesegnum - 1; 
    thischecksegs = abs(fft_matsig(tbgn:tend,:));
    thischecksegs = thischecksegs.*thischecksegs;
    shiftsum = zeros(length(stana_cfg.DopplerShiftCheckArray),size(thischecksegs,2));
    for shiftidx=1:length(stana_cfg.DopplerShiftCheckArray)
        thisshiftdeltaval = stana_cfg.DopplerShiftCheckArray(shiftidx);
        rowshiftvals = round([0:size(thischecksegs,1)-1]*thisshiftdeltaval);
        for h=1:size(thischecksegs,1)
            tempp = circshift(thischecksegs(h,:),rowshiftvals(h));
            shiftsum(shiftidx,:) = shiftsum(shiftidx,:) + tempp;
        end
        tempp = shiftsum(shiftidx,:); tempp = tempp-mean(tempp); tempp(tempp<0) = 0;
        shiftsum(shiftidx,:) = tempp;
    end
    
    % mask out the interference 
    [a,b] = max(shiftsum(find(stana_cfg.DopplerShiftCheckArray == 0),:));
    shiftsum(:,mod([b-50:b+50],size(shiftsum,2))+1) = 0;

    foundpeaks_all = [];
    for shiftidx=1:length(stana_cfg.DopplerShiftCheckArray)
        tempp = shiftsum(shiftidx,:); 
        [a,b] = peakfinder(tempp,median(tempp)*50); % NOTE: has been 50, using larger ones (200) will lose sats
        if length(a)
            thisone = [a;b;ones(1,length(a))*shiftidx];
            foundpeaks_all = [foundpeaks_all; transpose(thisone)];
        end
    end
    save_foundpeaks_all = foundpeaks_all;
    % NOTE: cannot remove weak peaks, will miss some sats 
    foundpeaks = [];
    while 1
        [thishei,b] = max(foundpeaks_all(:,2));
        thisloc = foundpeaks_all(b,1);
        tempp = foundpeaks_all(b,3);
        thisone = [thisloc, thishei, stana_cfg.DopplerShiftCheckArray(tempp), 0];
        foundpeaks = [foundpeaks; thisone];
        tempp = find(abs(foundpeaks_all(:,1)-thisloc) <= 100); % 10 kHz mask
        foundpeaks_all(tempp,:) = [];
        if size(foundpeaks_all,1) == 0
            break;
        end
    end
    tempp = find(foundpeaks(:,1) > stana_cfg.seglen_sampnum/2);
    foundpeaks(tempp,1) = foundpeaks(tempp,1) - stana_cfg.seglen_sampnum;
    for beaconidx=1:size(foundpeaks,1)
        if foundpeaks(beaconidx,4) 
            continue;
        end
        thiscluster = [beaconidx];
        for beaconidx2=1:size(foundpeaks,1)
            if beaconidx2 ==  beaconidx
                continue; 
            end
            if foundpeaks(beaconidx2,4) 
                continue;
            end
            fdiff = abs(foundpeaks(beaconidx,1) - foundpeaks(beaconidx2,1)); 
            est_f_dist_num = round(fdiff / stana_cfg.beacon_sep_f_loc_num);
            est_f_space = fdiff - est_f_dist_num*stana_cfg.beacon_sep_f_loc_num;
            if abs(est_f_space) < stana_cfg.beacon_drift_Hz*stana_cfg.seglen_sec
                thiscluster = [thiscluster, beaconidx2];
            end
        end
        currclusterid = max(foundpeaks(:,4))+1;
        foundpeaks(thiscluster,4) = currclusterid;

        % fprintf(1,'      found cluster %d (%d): ', currclusterid, length(thiscluster));
        % for h=1:length(thiscluster)
        %     fprintf(1,'%d, ', thiscluster(h));
        % end
        % fprintf(1,'\n');
    end

    thisbgn = (tbgn-1)*stana_cfg.seglen_sampnum+1;
    thisend = tend*stana_cfg.seglen_sampnum;
    checksig = starlink_time_sig(thisbgn:thisend);

    clusternum = length(unique(foundpeaks(:,4)));
    thissecfoundbeacons = [];
    for clusteridx=1:clusternum
        tempp = find(foundpeaks(:,4)==clusteridx);
        thiscluster = foundpeaks(tempp,:);
        if thiscluster(1,3) == 0 % the interference
            continue;   
        end

        % if size(thiscluster,1) < 10 continue;  end

        [a,usepeakidx] = max(thiscluster(:,2));
        usepeakloc = thiscluster(usepeakidx,1);
        usedriftrate = thiscluster(usepeakidx,3);
        heremaxdrift = 100;
        foundthisone = [];
        usepeaksig = zeros(size(thischecksegs));
        for segidx=1:size(thischecksegs,1)
            thisexploc = round(usepeakloc + usedriftrate*(segidx-1));
            tempp = [thisexploc-heremaxdrift:thisexploc+heremaxdrift];
            thisexprange = mod(tempp-1,size(thischecksegs,2)) + 1;
            usepeaksig(segidx,thisexprange) = thischecksegs(segidx,thisexprange);
            [a,b] = max(usepeaksig(segidx,:));
            foundthisone = [foundthisone; [a,b]];
        end
        usenum = floor(size(foundthisone,1)/10);
        [a,b] = sort(foundthisone(:,1), 'descend');
        useidx = sort(b(1:usenum));
        usetofit = foundthisone(useidx,:);
        save_useidx = useidx; save_usetofit = usetofit;
        usetofitloc = usetofit(:,2);

        for zzz=1:2
            [p,S] = polyfit(useidx,usetofitloc,1);
            hereslope = p(1);
            f = polyval(p,useidx);
            tempp = f - usetofitloc;
            [a,b] = sort(abs(tempp));
            tormvidx = b(end-2:end);
            useidx(tormvidx) = [];
            usetofitloc(tormvidx) = [];
        end
        hereslope = p(1);
        Doppler_f_change_Hz_sec = hereslope*seglen_base_freq_Hz/stana_cfg.seglen_sec;

        if Doppler_f_change_Hz_sec > -1000 || Doppler_f_change_Hz_sec < -6000
            continue;
        end

        thisbestdechirp_Hz_sec = stana_est_Doppler_rate(checksig,Doppler_f_change_Hz_sec,usepeakloc,stana_cfg);
        
        anasegexploc = round(usepeakloc*stana_cfg.analen_sec/stana_cfg.seglen_sec);
        anasegexprange = mod([anasegexploc-1000:anasegexploc+1000]-1, length(checksig)) + 1;
        new_dc_checksig = stana_dechirp(checksig, thisbestdechirp_Hz_sec, stana_cfg.SAMP_RATE_sps);
        fft_new_dc_checksig = fft(new_dc_checksig);
        tempp = zeros(size(fft_new_dc_checksig));
        tempp(anasegexprange) = fft_new_dc_checksig(anasegexprange);
        [a,b] = max(abs(tempp));

        thisbeacon.dechirp_Hz_sec = thisbestdechirp_Hz_sec; 
        thisbeacon.exploc = b;
        thisbeacon.highpeakval = a;
        thisbeacon.coarsecluster = thiscluster;

        fprintf(1,'      found cluster %2d with %2d peaks: ', thiscluster(1,4), size(thiscluster,1));
        fprintf(1,'Doppler rate: %5d Hz/sec, ', round(thisbeacon.dechirp_Hz_sec));
        fprintf(1,'highpeak loc: %7d, ', thisbeacon.exploc);
        fprintf(1,'highpeak val: %5d\n', round(thisbeacon.highpeakval));
        
        thissecfoundbeacons{length(thissecfoundbeacons)+1} = thisbeacon;
    end
    foundbeacons{checkidx} = thissecfoundbeacons;
end