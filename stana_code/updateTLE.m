command = 'curl -o All_sat.tle  https://celestrak.org/NORAD/elements/supplemental/sup-gp.php?FILE=starlink&FORMAT=tle';
status = system(command);
if status==0
    fprintf("TLE updated successfully\n");
end