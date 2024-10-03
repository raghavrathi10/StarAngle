function alltocheckclutsers = stana_sel_pairs(SAT)
    overlapmat = zeros(length(SAT));
    for satidx1=1:length(SAT)-1
        sat1 = SAT{satidx1}.info;
        span1 = [sat1(1,1):sat1(end,1)];
        for satidx2=satidx1+1:length(SAT)
            sat2 = SAT{satidx2}.info;
            span2 = [sat2(1,1):sat2(end,1)];
            tempp = intersect(span1,span2);
            overlapmat(satidx1,satidx2) = length(tempp);
        end
    end
    save_overlapmat = overlapmat;
    alltocheckclutsers = [];
    for pickidx=1:10 % 10 means max 5 sats 
        maxval = max(max(overlapmat));
        if maxval >= 10
            [a,b] = find(overlapmat == maxval);
            alltocheckclutsers = [alltocheckclutsers; [a b]];
            overlapmat(a,b) = 0;
        else
            break;
        end
    end
