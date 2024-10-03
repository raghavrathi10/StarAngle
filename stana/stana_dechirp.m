function outsig = stana_dechirp(insig, Doppler_f_change_Hz_sec, SAMP_RATE_sps)

Doppler_f_change_Hz_smpl = Doppler_f_change_Hz_sec/SAMP_RATE_sps;
Doppler_f_change_rad_smpl = 2*pi*Doppler_f_change_Hz_smpl/SAMP_RATE_sps;
Doppler_f_length_smpl = length(insig); 
% Doppler_f_change_phase = [0:Doppler_f_length_smpl-1].*[1:Doppler_f_length_smpl]*Doppler_f_change_rad_smpl/2;
Doppler_f_change_phase = [0:Doppler_f_length_smpl-1].*[0:Doppler_f_length_smpl-1]*Doppler_f_change_rad_smpl/2;
Doppler_f_change_wave = exp(1i*Doppler_f_change_phase);
outsig = insig./Doppler_f_change_wave;
% outsig = exp(1i*(angle(insig)-Doppler_f_change_phase).*abs(insig));