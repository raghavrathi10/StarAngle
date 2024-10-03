stana_exp_info = [];

expidx = 1; 
% good
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = -40;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-16-gaines/angle140/sig1_ant1',...  % good -50
    '../own_starlink_trace_int/06-16-gaines/angle140/sig5_ant1',...  % good -49
    '../own_starlink_trace_int/06-16-gaines/angle140/sig3_ant1'};  % good -41

stana_exp_info{expidx}.angles{2}.angleval_deg = 30;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/06-16-gaines/angle210/sig6_ant1',...  % good 25
    '../own_starlink_trace_int/06-16-gaines/angle210/sig2_ant1',...  % good 23 
    '../own_starlink_trace_int/06-16-gaines/angle210/sig1_ant1'};  % good 24

expidx = 2;
% good for now, only 2 good runs each angle
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = -120;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-19-lov/angle60/sig2_ant1',... % -116, 3 sats, good
    '../own_starlink_trace_int/06-19-lov/angle60/sig3_ant1'}; %  -125, 2 sats 
stana_exp_info{expidx}.angles{2}.angleval_deg = 30;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/06-19-lov/angle210/sig3_ant1',... % 39, one good pair
    '../own_starlink_trace_int/06-19-lov/angle210/sig4_ant1'}; % 34, 3 sats

expidx = 3; 
% good
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = 111;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-25-spirit/angle111/sig7_ant1',... % 117, good 
    '../own_starlink_trace_int/06-25-spirit/angle111/sig9_ant1',... % 107  
    '../own_starlink_trace_int/06-25-spirit/angle111/sig10_ant1'}; % 108, good 
stana_exp_info{expidx}.angles{2}.angleval_deg = 36;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/06-25-spirit/angle216/sig4_ant1',... % 20
    '../own_starlink_trace_int/06-25-spirit/angle216/sig8_ant1',... % 22
    '../own_starlink_trace_int/06-25-spirit/angle216/sig9_ant1'}; % 16


expidx = 4;
% good
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = -115;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-26-richards/angle65/sig4_ant1',... % -107, 2 sats, so so fit 
    '../own_starlink_trace_int/06-26-richards/angle65/sig6_ant1',... % -113, 2 sats,
    '../own_starlink_trace_int/06-26-richards/angle65/sig7_ant1'}; %  66, 2 sats, fake minimum 
stana_exp_info{expidx}.angles{2}.angleval_deg = -10;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/06-26-richards/angle170/sig1_ant1',... % -19, 2 sats
    '../own_starlink_trace_int/06-26-richards/angle170/sig4_ant1',... % -13, 2 sats
    '../own_starlink_trace_int/06-26-richards/angle170/sig5_ant1'}; % -22, 2 good sats


expidx = 5;
% good
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = 120;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-27-persi/angle300/sig3_ant1',... % 131
    '../own_starlink_trace_int/06-27-persi/angle300/sig7_ant1',... % 104, phase matching not good
    '../own_starlink_trace_int/06-27-persi/angle300/sig5_ant1'}; % 107
stana_exp_info{expidx}.angles{2}.angleval_deg = -88;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/06-27-persi/angle92/sig3_ant1',... % -86
    '../own_starlink_trace_int/06-27-persi/angle92/sig5_ant1',... % -89
    '../own_starlink_trace_int/06-27-persi/angle92/sig7_ant1'}; % -87

expidx = 6;
% good
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = 1;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-27-amol/angle181/sig4_ant1',... % 3
    '../own_starlink_trace_int/06-27-amol/angle181/sig5_ant1',... % 0
    '../own_starlink_trace_int/06-27-amol/angle181/sig12_ant1'};% 2, very good, 1 pairs 
stana_exp_info{expidx}.angles{2}.angleval_deg = 150;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/06-27-amol/angle330/sig2_ant1',... % 155, good 3 sats
    '../own_starlink_trace_int/06-27-amol/angle330/sig3_ant1',... % 156
    '../own_starlink_trace_int/06-27-amol/angle330/sig6_ant1'}; % 154, good, 5 sats, 9 pairs 
    
expidx = 7;
% good
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = -97;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-29-gaines1/angle83/sig3_ant1',... % -110, 3 pairs, 
    '../own_starlink_trace_int/06-29-gaines1/angle83/sig4_ant1',... % -109, 1 pair
    '../own_starlink_trace_int/06-29-gaines1/angle83/sig7_ant1'};% 147, fake min, 1 pair 
stana_exp_info{expidx}.angles{2}.angleval_deg = 11;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/06-29-gaines1/angle191/sig1_ant1',... % -3, 3 pairs 
    '../own_starlink_trace_int/06-29-gaines1/angle191/sig2_ant1',... % 11, 2 pairs
    '../own_starlink_trace_int/06-29-gaines1/angle191/sig6_ant1'}; % % -11, 1 pair,  

expidx = 8;
% 8 good, one angle
stana_exp_info{expidx}.angles = cell(1,1);
stana_exp_info{expidx}.angles{1}.angleval_deg = -145;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/06-29-gaines2/angle35/sig2_ant1',... % -158, 3 pairs 
    '../own_starlink_trace_int/06-29-gaines2/angle35/sig6_ant1',... % -161, 10 pairs 
    '../own_starlink_trace_int/06-29-gaines2/angle35/sig7_ant1'}; % -167, one pair

expidx = 9;
% good
stana_exp_info{expidx}.angles = cell(1,2);
stana_exp_info{expidx}.angles{1}.angleval_deg = -50;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/07-01-gaines3/angle130/sig5_ant1',... % -47, one pair 
    '../own_starlink_trace_int/07-01-gaines3/angle130/sig7_ant1',... % -56, one pair
    '../own_starlink_trace_int/07-01-gaines3/angle130/sig8_ant1'}; % -63, 3 pairs,
stana_exp_info{expidx}.angles{2}.angleval_deg = 165;
stana_exp_info{expidx}.angles{2}.filelist = {
    '../own_starlink_trace_int/07-01-gaines3/angle345/sig4_ant1',... % 148, 4 pairs, perfect phase match, why?
    '../own_starlink_trace_int/07-01-gaines3/angle345/sig6_ant1',... % 151, 3 pairs
    '../own_starlink_trace_int/07-01-gaines3/angle345/sig7_ant1'}; % 153, one good long pair


expidx = 10;
% good
stana_exp_info{expidx}.angles = cell(1,1);
stana_exp_info{expidx}.angles{1}.angleval_deg = -139;
stana_exp_info{expidx}.angles{1}.filelist = {
    '../own_starlink_trace_int/07-01-gaines-tree/angle41/sig2_ant1',... % -153, 2 pairs, not very good phase match 
    '../own_starlink_trace_int/07-01-gaines-tree/angle41/sig5_ant1',... % -142, 3 pairs, good
    '../own_starlink_trace_int/07-01-gaines-tree/angle41/sig7_ant1'}; % -147, 1 pair
