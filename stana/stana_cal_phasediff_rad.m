% antloc: one-D array of the ant locations on a line
% antangle: scalar of az of the ant line
% txangle: two numbers, az, el
% F: carrier freq
function res = stana_cal_phasediff_rad(antloc_m, antangle_rad, txangle_rad, F_Hz)

    D = diff(antloc_m);
    wavelength = physconst('LightSpeed')/F_Hz;
    in_az = antangle_rad - txangle_rad(:,1);
    in_el = txangle_rad(:,2);
    res = -D*cos(in_az).*cos(in_el)/wavelength*2*pi;
