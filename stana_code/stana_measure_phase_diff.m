function phasediffres = stana_measure_phase_diff(alltocheckclutsers,STANA_ant_num,checkmergesegnum,ANTCFO,ANT_DopplerRate_Hz_sec,SAT,starlink_time_sig,starlink_time_sig_2,stana_cfg)

phasediffres = cell(1,size(alltocheckclutsers,1));
siglen_phaserecon = round(length(starlink_time_sig)/stana_cfg.reconphasefactor); 

for checksatpairidx=1:size(alltocheckclutsers,1)
    tocheckclutsers = alltocheckclutsers(checksatpairidx,:);
    phasediffres{checksatpairidx}.satid = tocheckclutsers;
    phasediffres{checksatpairidx}.usepeakloc = cell(1,STANA_ant_num); 
    for STANA_ant_idx=1:STANA_ant_num
        phasediffres{checksatpairidx}.usepeakloc{STANA_ant_idx} = zeros(checkmergesegnum,STANA_ant_num);
    end
    phasediffres{checksatpairidx}.usesigmag = phasediffres{checksatpairidx}.usepeakloc; 
    % phasediffres{checksatpairidx}.dbg_reconsig = zeros(2, length(starlink_time_sig));

    fprintf(1, 'phase measure pair %d of %d -- sat (%d, %d): \n', checksatpairidx, size(alltocheckclutsers,1), tocheckclutsers(1), tocheckclutsers(2));
    vsavg_0 = zeros(1,checkmergesegnum);
    gotdataseg_flag = zeros(1,checkmergesegnum);
    print_counter = 0;
    for checkidx=1:checkmergesegnum
        sat1foundtimeidx = find(SAT{tocheckclutsers(1)}.info(:,1) == checkidx);
        sat2foundtimeidx = find(SAT{tocheckclutsers(2)}.info(:,1) == checkidx);
        if length(sat1foundtimeidx) == 0 || length(sat2foundtimeidx) == 0
            continue;
        end
        satidxvals = [sat1foundtimeidx(1),sat2foundtimeidx(1)];

        thisanasegbgn = (checkidx-1)*stana_cfg.analen_sampnum+1;
        thisanasegend = thisanasegbgn + stana_cfg.analen_sampnum-1;
        checksig = starlink_time_sig(thisanasegbgn:thisanasegend);
        if STANA_ant_num == 2
            checksig_2 = starlink_time_sig_2(thisanasegbgn:thisanasegend);
        end

        stana_recon = cell(length(tocheckclutsers),STANA_ant_num);
        thissecfailed_flag = 0;
        for satidx=1:length(tocheckclutsers)
    
            thisbeaconcluster_dechirp_Hz_sec = SAT{tocheckclutsers(satidx)}.info(satidxvals(satidx),stana_cfg.satinfo_idx_dechirp_Hz_sec);
            thisbeaconcluster_exploc = SAT{tocheckclutsers(satidx)}.info(satidxvals(satidx),stana_cfg.satinfo_idx_exploc);
            thisanasegsig = stana_dechirp(checksig, thisbeaconcluster_dechirp_Hz_sec, stana_cfg.SAMP_RATE_sps); 
            if STANA_ant_num == 2
                % heredoprate = thisbeaconcluster_dechirp_Hz_sec+ANT_DopplerRate_Hz_sec(checkidx);
                heredoprate = thisbeaconcluster_dechirp_Hz_sec;
                thisanasegsig_2 = stana_dechirp(checksig_2, heredoprate, stana_cfg.SAMP_RATE_sps);
            end
    
            adjbeaconlocs = [thisbeaconcluster_exploc]; 
            adjbeaconlocs_2 = adjbeaconlocs +  ANTCFO(checkidx);
            win_one_side_len = [50,50];
            % NOTE: older beacon selection code in stana_examine_all_beacons_of_a_sat;

            takeidx = [stana_cfg.analen_sampnum-win_one_side_len(1)+1:stana_cfg.analen_sampnum,1:win_one_side_len(2)+1];
            phasediffres{checksatpairidx}.usepeakloc{satidx}(checkidx,:) = [adjbeaconlocs,adjbeaconlocs_2];
            for STANA_ant_idx=1:STANA_ant_num
                if STANA_ant_idx == 1
                    thisantanasegsig = thisanasegsig;
                    use_adjbeaconlocs = adjbeaconlocs;
                else
                    thisantanasegsig = thisanasegsig_2;
                    use_adjbeaconlocs = adjbeaconlocs_2;
                end
                fft_thisantanasegsig = fft(thisantanasegsig);
                reconbeaconsig = zeros(length(use_adjbeaconlocs),stana_cfg.analen_sampnum);
                for beaconidx=1:length(use_adjbeaconlocs)
                    fft_base_rx_sig = circshift(fft_thisantanasegsig,-use_adjbeaconlocs(beaconidx));
                    filtered_fft_base_rx_sig = zeros(1,stana_cfg.analen_sampnum); 
                    filtered_fft_base_rx_sig(takeidx) = fft_base_rx_sig(takeidx);
                    ifft_filtered_fft_base_rx_sig = ifft(filtered_fft_base_rx_sig);
                    reconbeaconsig(beaconidx,:) = ifft_filtered_fft_base_rx_sig;
                end
                stana_recon{satidx,STANA_ant_idx}.sig = reconbeaconsig;
                phasediffres{checksatpairidx}.usesigmag{satidx}(checkidx,STANA_ant_idx) = mean(abs(reconbeaconsig));
                if STANA_ant_idx == 1
                    % phasediffres{checksatpairidx}.dbg_reconsig(satidx,thisanasegbgn:thisanasegend) = reconbeaconsig(1,:);
                end
            end
            if thissecfailed_flag 
                continue;
            end
        end
    
        foundanglediff = zeros(length(tocheckclutsers),stana_cfg.analen_sampnum);
        for satidx=1:length(tocheckclutsers)
            foundanglediff(satidx,:) = unwrap(angle(stana_recon{satidx,1}.sig(1,:)./stana_recon{satidx,2}.sig(1,:)));
        end
        herefoundphasediff_0 = foundanglediff(1,:)-foundanglediff(2,:);
    
        winlen = length(herefoundphasediff_0)/100;  
        endignorenum = 5;
        endignoreadj = 1-endignorenum*2/winlen;

        tempp = reshape(herefoundphasediff_0,winlen,length(herefoundphasediff_0)/winlen);
        lpfphasediff_0 = mean(tempp);
        lpfphasediff_1 = lrfh_own_unwrap(lpfphasediff_0,pi/10);
        lpfphasediff = lpfphasediff_1(endignorenum+1:end-endignorenum);

        [a,b] = polyfit([0:length(lpfphasediff)-1], lpfphasediff,1);
        hereslope0 = round(a(1)*length(lpfphasediff)/pi/2*endignoreadj); % to remove int Hz level offset
        hereslope = hereslope0/length(lpfphasediff)*pi*2*endignoreadj;
        hereadjwave =  [0:length(lpfphasediff)-1]*hereslope;
        herenewave = lpfphasediff - hereadjwave;
        [aa,bb] = polyfit([0:length(herenewave)-1], herenewave,1);
        hereanawave = polyval(aa,[0:length(herenewave)-1]);
        herenewnewwave = hereanawave - herenewave;
        % plot(herenewave); hold on; plot(hereanawave); hold off
        herethreshtousedata = 5;

        localfittingscore = norm(herenewnewwave);
        localmeares = mean(herenewave);
        % NOTE: for dnsamplefacotr 100, 100 good, 200 will let in bad results
        if localfittingscore < herethreshtousedata 
            gotdataseg_flag(checkidx) = 1;
            vsavg_0(checkidx) = localmeares;
        else
            fprintf(1, 'NA-');
        end
        fprintf(1, '[%d: %4.2f (%d)], ', checkidx, localmeares*180/pi, round(localfittingscore));

        print_counter = print_counter + 1;
        if mod(print_counter,5) == 0
            fprintf(1, '\n');
        end
    end
    if mod(print_counter,5) ~= 0
        fprintf(1, '\n');
    end

    withdataidx = find(gotdataseg_flag);
    phasediffres{checksatpairidx}.vsidx = withdataidx;

    if length(withdataidx)
        vsavg = vsavg_0(withdataidx);
        vsavg = unwrap(vsavg); % NOTE: may miss a few points, but typically a straight line
        phaseadj = [-1:1]*2*pi;
        testval = vsavg(1) + phaseadj;
        [a,b] = min(abs(testval));
        vsavg = vsavg + phaseadj(b);
        phasediffres{checksatpairidx}.vsavg = vsavg;
    else
        phasediffres{checksatpairidx}.vsavg = [];
    end

    if isfield(SAT{tocheckclutsers(1)},'cal_rcvphasediff_rad') && isfield(SAT{tocheckclutsers(2)},'cal_rcvphasediff_rad')
        phasediffres{checksatpairidx}.calval_rad = SAT{tocheckclutsers(2)}.cal_rcvphasediff_rad - SAT{tocheckclutsers(1)}.cal_rcvphasediff_rad;
    end
end   