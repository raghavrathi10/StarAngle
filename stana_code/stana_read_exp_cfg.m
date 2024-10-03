function stana_exp_cfg = stana_read_exp_cfg(thisfilename_cfg)

    cfgfid = fopen(thisfilename_cfg);
    stana_exp_cfg.tsstr = fgetl(cfgfid);
    tempp = fgetl(cfgfid); stana_exp_cfg.duration_sec = sscanf(tempp,'%d\n');
    tempp = fgetl(cfgfid); stana_exp_cfg.lat_deg = sscanf(tempp,'%f\n');
    tempp = fgetl(cfgfid); stana_exp_cfg.lon_deg = sscanf(tempp,'%f\n');
    tempp = fgetl(cfgfid); stana_exp_cfg.LNB_az_degree = sscanf(tempp,'%f\n');
    tempp = fgetl(cfgfid); stana_exp_cfg.LNB_dist_m = sscanf(tempp,'%f\n');
    fclose(cfgfid);