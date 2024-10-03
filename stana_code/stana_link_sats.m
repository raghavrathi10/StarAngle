function [SAT,dbg_info] = stana_link_sats(foundbeacons,stana_cfg)

SAT = [];
checkmergesegnum = length(foundbeacons);
foundnum = zeros(1,checkmergesegnum);
for checkidx=1:checkmergesegnum
    foundnum(checkidx) = length(foundbeacons{checkidx});
end
linked_flag = zeros(checkmergesegnum,max(foundnum)); 
maxheival = zeros(checkmergesegnum,max(foundnum));
for checkidx=1:checkmergesegnum
    for clusteridx=1:length(foundbeacons{checkidx})
        maxheival(checkidx,clusteridx) = foundbeacons{checkidx}{clusteridx}.highpeakval;
    end
end
maxheival = ceil(maxheival/max(max(maxheival))*10);
dbg_info.maxheival = maxheival;


foundsatidx = 0;
while 1
    thissat = [];
    thissatdetails = [];
    for checkidx=1:checkmergesegnum
        for clusteridx=1:length(foundbeacons{checkidx})
            if linked_flag(checkidx,clusteridx) == 0
                thiscluster = foundbeacons{checkidx}{clusteridx};
                thissat = [checkidx,clusteridx,thiscluster.dechirp_Hz_sec, thiscluster.dechirp_Hz_sec, ...
                    stana_check_neg_freq(thiscluster.exploc,stana_cfg.analen_sampnum),thiscluster.exploc, thiscluster.highpeakval];
                thissatdetails{1} = thiscluster;
                foundsatidx = foundsatidx + 1;
                linked_flag(checkidx,clusteridx) = foundsatidx;
                break;
            end
        end
        if length(thissat) 
            break;
        end
    end
    if length(thissat) == 0
        break;
    end
    for checkidx=thissat(1,1)+1:checkmergesegnum
        tolastdist = checkidx - thissat(end,1);
        if tolastdist > stana_cfg.linkjumpmax
            break;
        end
        if size(thissat,1) == 1
            nextexpect = thissat(end,3);
        elseif size(thissat,1) == 2
            p = polyfit(thissat(:,1),thissat(:,3),1);
            nextexpect = polyval(p, checkidx);
        else
            uselen = min(size(thissat,1),6);
            useidx = [size(thissat,1)-uselen+1:size(thissat,1)];
            p = polyfit(thissat(useidx,1),thissat(useidx,3),2);
            nextexpect = polyval(p, checkidx);
        end
        for clusteridx=1:length(foundbeacons{checkidx})
            if linked_flag(checkidx,clusteridx)
                continue;
            end
            thisval = foundbeacons{checkidx}{clusteridx}.dechirp_Hz_sec;
            thispeakhei = foundbeacons{checkidx}{clusteridx}.highpeakval;
            thisexploc = foundbeacons{checkidx}{clusteridx}.exploc;
            thisfreq = stana_check_neg_freq(thisexploc,stana_cfg.analen_sampnum); 
            lastfreq = thissat(end,5); 
            if abs(thisval - nextexpect) < 100
                tempp = mod(thisfreq-lastfreq-thisval*tolastdist, stana_cfg.beacon_sep_f_loc_num_in_anaseg);
                tempp1 = stana_check_neg_freq(tempp,stana_cfg.beacon_sep_f_loc_num_in_anaseg);
                condi2 = abs(tempp1) < 1000;
                if condi2
                    thissat = [thissat; [checkidx,clusteridx,thisval,nextexpect,thisfreq, thisexploc, thispeakhei]];
                    thissatdetails{length(thissatdetails)+1} = foundbeacons{checkidx}{clusteridx}; 
                    linked_flag(checkidx,clusteridx) = foundsatidx;
                    break;
                end
            end
        end        
    end
    if size(thissat,1) >= 10
        currlen = length(SAT)+1;
        SAT{currlen}.info = thissat;
        SAT{currlen}.details = thissatdetails;
        secbeacons = cell(1,size(thissat,1));
        beaconrange_Hz = [stana_cfg.seglen_sampnum,-stana_cfg.seglen_sampnum]/stana_cfg.seglen_sec; 
        max_power_beaconrange_Hz = [stana_cfg.seglen_sampnum,-stana_cfg.seglen_sampnum]/stana_cfg.seglen_sec; 
        for secidx=1:size(thissat,1)
            a = round(thissatdetails{secidx}.coarsecluster(:,1)/stana_cfg.seglen_sec);
            b = thissatdetails{secidx}.coarsecluster(:,2); 
            [aa,bb] = sort(a);
            secbeacons{secidx}.beaconfreq_Hz = a(bb);
            secbeacons{secidx}.beaconhei = b(bb);
            beaconrange_Hz(1) = min(beaconrange_Hz(1),min(a)); 
            beaconrange_Hz(2) = max(beaconrange_Hz(2),max(a)); 
            max_power_beaconrange_Hz(1) = min(max_power_beaconrange_Hz(1), thissat(secidx,stana_cfg.satinfo_idx_freq));
            max_power_beaconrange_Hz(2) = max(max_power_beaconrange_Hz(2), thissat(secidx,stana_cfg.satinfo_idx_freq));
        end
        SAT{currlen}.secbeacons = secbeacons;
        SAT{currlen}.beaconrange_Hz = beaconrange_Hz;

        fprintf(1, 'found SAT %d -- %d points (%d to %d), freq [%d, %d] Hz, avg peakhei %.2f\n', length(SAT), size(thissat,1), thissat(1,1), thissat(end,1), max_power_beaconrange_Hz(1), max_power_beaconrange_Hz(2), mean(thissat(:,7)));

        for secidx=1:size(thissat,1)
            fprintf(1, '       sec %2d (%2d): ', thissat(secidx,1), length(secbeacons{secidx}.beaconfreq_Hz));
            for h=1:length(secbeacons{secidx}.beaconfreq_Hz)
                fprintf(1, '%5d, ', secbeacons{secidx}.beaconfreq_Hz(h)/100)
            end
            fprintf(1, '\n                    ');
            for h=1:length(secbeacons{secidx}.beaconfreq_Hz)
                fprintf(1, '%5d, ', round(secbeacons{secidx}.beaconhei(h)/1000))
            end
            fprintf(1, '\n');
        end
    end
end
dbg_info.linked_flag = linked_flag;