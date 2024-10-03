function thisbestdechirp_Hz_sec = stana_est_Doppler_rate(checksig,Doppler_f_change_Hz_sec,usepeakloc,stana_cfg)

            dc_checksig = stana_dechirp(checksig, Doppler_f_change_Hz_sec, stana_cfg.SAMP_RATE_sps);
            hlen = length(dc_checksig);
            dncvtwave = exp(1i*[0:hlen-1]*2*pi/hlen*usepeakloc*stana_cfg.analen_sec/stana_cfg.seglen_sec);
            dncvt_dc_checksig = dc_checksig./dncvtwave;
            dnsmpf = 10;
            dnsmp_dncvt_dc_checksig = dncvt_dc_checksig(1:dnsmpf:end);
            peakrange = mod([-1000:1000]-1,length(dnsmp_dncvt_dc_checksig))+1;
            for scanidx=1:2
                if scanidx == 1
                    this_trace_change_Hz_sec = stana_cfg.anaseg_trace_change_Hz_sec;
                else
                    this_trace_change_Hz_sec = [];
                    for h=1:2
                        thisone = stana_cfg.anaseg_trace_change_fine_Hz_sec + stana_cfg.anaseg_trace_change_Hz_sec(sorteddsidx(h));
                        this_trace_change_Hz_sec = [this_trace_change_Hz_sec, thisone];
                    end
                    this_trace_change_Hz_sec = unique(this_trace_change_Hz_sec);
                end
                dcscore = zeros(1,length(this_trace_change_Hz_sec));
                for dechirpidx=1:length(this_trace_change_Hz_sec)
                    dechirp_Hz_sec = this_trace_change_Hz_sec(dechirpidx);
                    thissig = stana_dechirp(dnsmp_dncvt_dc_checksig, dechirp_Hz_sec, stana_cfg.SAMP_RATE_sps/dnsmpf);
                    fft_thissig = fft(thissig);
                    tempp = zeros(size(fft_thissig));
                    tempp(peakrange) = fft_thissig(peakrange);
                    dcscore(dechirpidx) = max(abs(tempp));
                end
                [a,maxdsidx] = max(dcscore);
                [aa,sorteddsidx] = sort(dcscore, 'descend');
            end
            thisbestdechirp_Hz_sec = this_trace_change_Hz_sec(maxdsidx) + Doppler_f_change_Hz_sec;