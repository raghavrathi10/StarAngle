function RES_usaz = stana_est_user_az(alltocheckclutsers,checkmergesegnum,LNB_dist_m,SAT,phasediffres, Fc) 
    
    LNB_az_degree_vals = [-180:180];
    scores = zeros(length(LNB_az_degree_vals),size(alltocheckclutsers,1));
    weight = zeros(checkmergesegnum,size(alltocheckclutsers,1));
    scoresdetails = zeros(length(LNB_az_degree_vals),size(alltocheckclutsers,1),checkmergesegnum); 
    diffdetails = zeros(length(LNB_az_degree_vals),size(alltocheckclutsers,1),checkmergesegnum); 
    opdiff = zeros(checkmergesegnum,size(alltocheckclutsers,1))';
    for checksatpairidx=1:size(alltocheckclutsers,1)
        tocheckclutsers = alltocheckclutsers(checksatpairidx,:);
        sat1idx = tocheckclutsers(1);
        sat2idx = tocheckclutsers(2);
        thispairuseidx = phasediffres{checksatpairidx}.vsidx;
        wei1 = phasediffres{checksatpairidx}.usesigmag{1}(thispairuseidx,1);
        wei2 = phasediffres{checksatpairidx}.usesigmag{2}(thispairuseidx,1);
        thisuseweight = wei1.*wei1.*wei2.*wei2;
        weight(thispairuseidx,checksatpairidx) = thisuseweight';
        for degidx=1:length(LNB_az_degree_vals)
            thisdeg = LNB_az_degree_vals(degidx);
            val1 = stana_cal_phasediff_rad([0,LNB_dist_m], thisdeg*pi/180, [SAT{sat1idx}.cal_az ;SAT{sat1idx}.cal_el]'*pi/180, Fc);
            val2 = stana_cal_phasediff_rad([0,LNB_dist_m], thisdeg*pi/180, [SAT{sat2idx}.cal_az ;SAT{sat2idx}.cal_el]'*pi/180, Fc);
            calval_rad = (val2-val1);
            plottry = calval_rad(thispairuseidx);
            plotadd = [-2:2]*2*pi; plotscore = zeros(1,length(plotadd));
            for h=1:length(plotscore)
                tempp = plottry + plotadd(h);
                tempp1 = tempp' - phasediffres{checksatpairidx}.vsavg;
                plotscore(h) = sum(tempp1.*tempp1);
            end
            [a,b] = min(plotscore);
            usevals = plottry + plotadd(b);
            thisdiff = usevals - phasediffres{checksatpairidx}.vsavg';
            thisscorevec = thisdiff.*thisdiff.*thisuseweight;
            scores(degidx,checksatpairidx) = sum(thisscorevec);
            scoresdetails(degidx,checksatpairidx,thispairuseidx) = thisscorevec;
            diffdetails(degidx,checksatpairidx,:) = calval_rad(1:checkmergesegnum);
        end
    end
    normweightval = max(max(weight));
    scores = scores/normweightval;
    weight = weight/normweightval;
    scoresdetails = scoresdetails/normweightval;

    sumscores = zeros(1, length(LNB_az_degree_vals));
    for degidx=1:length(LNB_az_degree_vals)
        for checkidx=1:checkmergesegnum
            [usepairwei,usepairidx] = sort(weight(checkidx,:),'descend');
            satused = [];
            for pairidxidx=1:length(usepairidx)
                if usepairwei(pairidxidx) == 0
                    break;
                end
                pairidx = usepairidx(pairidxidx);
                tocheckclutsers = alltocheckclutsers(pairidx,:);
                if length(intersect(tocheckclutsers,satused)) < 2 
                    satused = union(satused,tocheckclutsers);
                    sumscores(degidx) = sumscores(degidx) + scoresdetails(degidx,pairidx,checkidx);
                end
            end
        end
    end        

    [estcost,b] = min(sumscores);
    estval = LNB_az_degree_vals(b);
    opdiff(:,:)  = diffdetails(b,:,:);
    opdiff = opdiff';

    RES_usaz.estval = estval;
    RES_usaz.estcost = estcost;
    RES_usaz.LNB_az_degree_vals = LNB_az_degree_vals;
    RES_usaz.sumscores =  sumscores;
    RES_usaz.opdiff = opdiff;
    RES_usaz.scores = scores;