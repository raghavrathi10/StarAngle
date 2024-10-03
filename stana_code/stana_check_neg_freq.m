function res = stana_check_neg_freq(a, b)
    if a > b/2
        res = a - b;
    else
        res = a;
    end