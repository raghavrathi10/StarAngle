function SatIDs = stana_find_flyover_sats(stana_exp_cfg,alltelfilename)

look_back_sec = 120;
loo_forward_sec = 180;
sampleTime = 10;
minElevationAngle = 30;
testpoint = round([stana_exp_cfg.duration_sec/2]);

exp_startTime = datetime(stana_exp_cfg.tsstr);
startTime = exp_startTime - seconds(look_back_sec);
stopTime = startTime + seconds(look_back_sec+loo_forward_sec);
sc = satelliteScenario(startTime,stopTime,sampleTime);
gs = groundStation(sc,stana_exp_cfg.lat_deg,stana_exp_cfg.lon_deg,"MinElevationAngle",minElevationAngle);

sat = satellite(sc,alltelfilename);
ac = access(sat,gs);
foundlist = [];
for testtimeidx=1:length(testpoint)
    thistime = exp_startTime + seconds(testpoint(testtimeidx));
    
    d = datenum(thistime);
    dt = datetime(d, 'ConvertFrom', 'datenum');
    dt.Format = 'MMMM d, yyyy - HH:mm:ss';
    fprintf('%s -- \n', dt);

    s = accessStatus(ac,thistime);
    thisone = find(s)';
    foundlist = [foundlist, thisone];

    for h=1:length(thisone)
        fprintf(1,'        %s\n', sat(thisone(h)).Name),
    end
end
foundlist = unique(foundlist);

foundsats = sat(foundlist);
SatIDs = cell(1,length(foundlist));
for h=1:length(foundlist)
    SatIDs{h} = foundsats(h).Name;
end
if length(testpoint) > 1
    fprintf('Overall found %d satellites: \n', length(SatIDs));
    for h=1:length(SatIDs)
        fprintf(1,'        %s\n', SatIDs{h})
    end
end