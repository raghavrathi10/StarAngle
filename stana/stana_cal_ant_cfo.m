function [ANTCFO, ANT_DopplerRate_Hz_sec] = stana_cal_ant_cfo(checkmergesegnum,SAT,starlink_time_sig,starlink_time_sig_2,stana_cfg)

    fprintf(1, 'calculating the frequency diff between two antennas: \n')
    print_counter = 0;
    ANTCFO = zeros(1,checkmergesegnum);
    ANT_DopplerRate_Hz_sec = zeros(1,checkmergesegnum);
    for checkidx=1:checkmergesegnum
        thisanasegbgn = (checkidx-1)*stana_cfg.analen_sampnum+1;
        thisanasegend = thisanasegbgn + stana_cfg.analen_sampnum-1;
        checksig = starlink_time_sig(thisanasegbgn:thisanasegend);
        checksig_2 = starlink_time_sig_2(thisanasegbgn:thisanasegend);

        scores = zeros(length(SAT),2);
        for satidx=1:length(SAT)
            thisidx = find(SAT{satidx}.info(:,1) == checkidx);
            if length(thisidx)
                scores(satidx,:) = [thisidx, SAT{satidx}.details{thisidx}.highpeakval];
            end
        end
        [a,b] = max(scores(:,2));
        if a == 0
            if checkidx == 1
                antfreqshift = 0;
            else
                antfreqshift = ANTCFO(checkidx-1);
            end
        else
            thisbeaconcluster = SAT{b}.details{scores(b,1)};

            thisanasegsig = stana_dechirp(checksig, thisbeaconcluster.dechirp_Hz_sec, stana_cfg.SAMP_RATE_sps); 
            abs_fft_thisanasegsig = abs(fft(thisanasegsig));
            if 0
                thisbestdechirp_Hz_sec = stana_est_Doppler_rate(checksig_2,thisbeaconcluster.dechirp_Hz_sec,thisbeaconcluster.exploc,stana_cfg);
            else
                thisbestdechirp_Hz_sec = thisbeaconcluster.dechirp_Hz_sec;
            end
            ANT_DopplerRate_Hz_sec(checkidx) = thisbestdechirp_Hz_sec - thisbeaconcluster.dechirp_Hz_sec;
            thisanasegsig_2 = stana_dechirp(checksig_2, thisbestdechirp_Hz_sec, stana_cfg.SAMP_RATE_sps);
            abs_fft_thisanasegsig_2 = abs(fft(thisanasegsig_2));

            [peakloc, peakhei] = stana_get_peaks(abs_fft_thisanasegsig, median(abs_fft_thisanasegsig)*6, stana_cfg.anaseg_beacon_peak_cover_point_num);
            [peakloc_2, peakhei_2] = stana_get_peaks(abs_fft_thisanasegsig_2, median(abs_fft_thisanasegsig_2)*6, stana_cfg.anaseg_beacon_peak_cover_point_num);

            closedist = [];
            for h=1:length(peakloc)
                tempp = peakloc_2 - peakloc(h);
                [a,b] = find(abs(tempp)<stana_cfg.maxantfreqdiff_loc_num_ana_seg);
                closedist = [closedist, tempp(b)];
            end
            if length(closedist) <= 2
                if checkidx == 1
                    antfreqshift = 0;
                else
                    antfreqshift = ANTCFO(checkidx-1);
                end
            else
                roundclosedist = round(closedist/200);
                a = mode(roundclosedist);
                useidx = find(roundclosedist == a);
                antfreqshift = round(mean(closedist(useidx)));
            end
            ANTCFO(checkidx) = round(antfreqshift);
        end
        fprintf(1, ' (%2d: %6d, %4d), ', checkidx, ANTCFO(checkidx), round(ANT_DopplerRate_Hz_sec(checkidx)));
        print_counter = print_counter + 1;
        if mod(print_counter,5) == 0
            fprintf(1, '\n');
        end
    end
    if mod(print_counter,5) ~= 0
        fprintf(1, '\n');
    end
