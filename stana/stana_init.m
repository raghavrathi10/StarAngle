% starlink TLE:
% https://celestrak.org/NORAD/elements/supplemental/sup-gp.php?FILE=starlink&FORMAT=tle

stana_cfg.fc = 11.950e9;

stana_cfg.beacon_sep_Hz = 43945;
stana_cfg.beacon_drift_Hz = 2000; 

stana_cfg.SAMP_RATE_sps = 2000000; 
stana_cfg.seglen_sec = 0.01;
stana_cfg.seglen_sampnum = ceil(stana_cfg.SAMP_RATE_sps*stana_cfg.seglen_sec);

stana_cfg.beacon_sep_f_loc_num = round(stana_cfg.beacon_sep_Hz*stana_cfg.seglen_sec);

stana_cfg.analen_sec = 1; 
stana_cfg.analen_sampnum = ceil(stana_cfg.SAMP_RATE_sps*stana_cfg.analen_sec);
stana_cfg.beacon_sep_f_loc_num_in_anaseg = round(stana_cfg.beacon_sep_Hz*stana_cfg.analen_sec);
stana_cfg.anaseg_beacon_peak_cover_Hz = 500;
stana_cfg.anaseg_beacon_peak_cover_point_num = ceil(stana_cfg.anaseg_beacon_peak_cover_Hz/stana_cfg.analen_sec); 
stana_cfg.anaseg_trace_change_Hz_sec = [-100:10:100];
stana_cfg.anaseg_trace_change_fine_Hz_sec = [-5:5];

stana_cfg.maxantfreqdiff_Hz = 21000;
stana_cfg.maxantfreqdiff_loc_num_ana_seg = round(stana_cfg.maxantfreqdiff_Hz/stana_cfg.analen_sec);

stana_cfg.deDop_expand_factor = 10;
stana_cfg.deDop_seglen_sec = stana_cfg.seglen_sec*stana_cfg.deDop_expand_factor;
stana_cfg.deDop_seglen_sampnum = ceil(stana_cfg.SAMP_RATE_sps*stana_cfg.deDop_seglen_sec);
stana_cfg.deDop_seglen_base_freq_Hz = 1/stana_cfg.deDop_seglen_sec;

stana_cfg.DopplerLinearLen_sec = stana_cfg.analen_sec; % assuming the Doppler is linear within this much time
stana_cfg.mergesegnum = stana_cfg.DopplerLinearLen_sec/stana_cfg.seglen_sec; % integer
stana_cfg.DopplerMaxOneSec_Hz = 5000;
stana_cfg.DopplerShiftMaxOneSecPoint = ceil(stana_cfg.DopplerMaxOneSec_Hz*stana_cfg.seglen_sec);
stana_cfg.DopplerShiftCheckArray = [-0.5:0.1:0.5];

stana_cfg.antenna_sync_flag = 0;

stana_cfg.maxclusternum = 100;
stana_cfg.linkjumpmax = 5;

stana_cfg.peak_num_take_max = 6; % 
stana_cfg.sync_peak_thresh_coef = 6; 
stana_cfg.sync_peak_move_thresh = 2; %
stana_cfg.sync_peak_look_around = 10; % 
stana_cfg.sync_peak_look_thresh = stana_cfg.sync_peak_look_around/2; 

stana_cfg.minwinoneside = 5;
stana_cfg.maxwinoneside = 100;
stana_cfg.scanwin = [-3:3];

stana_cfg.reconphasefactor = 100; 

stana_cfg.anameawiggle_sec = [-3:0.25:3];

stana_cfg.satinfo_idx_sec = 1;
stana_cfg.satinfo_idx_clusteridx = 2;
stana_cfg.satinfo_idx_dechirp_Hz_sec = 3;
stana_cfg.satinfo_idx_freq = 5;
stana_cfg.satinfo_idx_exploc = 6;
stana_cfg.satinfo_idx_peakhei = 7;

stana_cfg.checkaroundnum = 20;
stana_cfg.checkaroundarray = [-stana_cfg.checkaroundnum:stana_cfg.checkaroundnum];

stana_USE_WRAPPER = 0;

plotmarkers = [];
plotmarkers{1} = '*';
plotmarkers{2} = '+';
plotmarkers{3} = 'o';
plotmarkers{4} = '<';
plotmarkers{5} = 's';
plotmarkers{6} = 'h';
plotmarkers{7} = 'd';
plotmarkers{8} = 'x';
plotmarkers{9} = 'p';
plotmarkers{10} = '>';

plotcolors = [];
plotcolors{1} = "#0072BD";	
plotcolors{2} = "#D95319";
plotcolors{3} = "#EDB120";	
plotcolors{4} = "#7E2F8E";	
plotcolors{5} = "#77AC30";	
plotcolors{6} = "#4DBEEE";	
plotcolors{7} = "#A2142F";
plotcolors{8} = "r";
plotcolors{9} = "g";
plotcolors{10} = "b";