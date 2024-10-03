function [peakloc, peakhei] = stana_get_peaks(sig, thresh, masklen)

    [peakloc, peakhei] = peakfinder(sig,thresh); 
    
    keepflag = ones(1,length(peakloc));
    for h1=1:length(peakloc)
        for h2=1:length(peakloc)
            if h1==h2 continue; end
            if abs(peakloc(h1)-peakloc(h2)) < masklen
                if peakhei(h1) > peakhei(h2)
                    keepflag(h2) = 0;
                end
            end
        end
    end
    peakloc = peakloc(find(keepflag));
    peakhei = peakhei(find(keepflag));
