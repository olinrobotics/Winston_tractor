%% Exponential Atmospheric Model
% U.S. Standard Atmosphere 1976 for 0 Km, CIRA-72 for 25-500 Km and CIRA-72
% with exospheric temperature $T_{inf} = 1000 [K]$ for 500-1000 Km. The
% Scale heights $H$ have been adjusted to maintain a piecewise-continuous
% formulation for the density.
classdef iPWatm < handle
    properties (Constant = true, GetAccess = public)
        % first column: base altitude $h_0 [Km]$
        % second column: nominal density $\rho_0 [Kg/m^3]$
        % third column: scale height $H [Km]$
        exp_atm_model =  [ 0	1.225     7.249
                           25	3.899e-2  6.349
                           30	1.774e-2  6.682
                           40	3.972e-3  7.554
                           50	1.057e-3  8.382
                           60	3.206e-4  7.714
                           70	8.770e-5  6.549
                           80	1.905e-5  5.799
                           90	3.396e-6  5.382
                           100	5.297e-7  5.877
                           110	9.661e-8  7.263
                           120	2.438e-8  9.473
                           130	8.484e-9  12.636
                           140	3.845e-9  16.149
                           150	2.070e-9  22.523
                           180	5.464e-10 29.740
                           200	2.789e-10 37.105
                           250	7.248e-11 45.546
                           300	2.418e-11 53.628
                           350	9.518e-12 53.298
                           400	3.725e-12 58.515
                           450	1.585e-12 60.828
                           500	6.967e-13 63.822
                           600	1.454e-13 71.835
                           700	3.614e-14 88.667
                           800	1.170e-14 124.640
                           900	5.245e-15 181.050
                           1000	3.019e-15 268.000];
        
        h_idx = UW.iPWatm.exp_atm_model(:,1);
        rho_0 = UW.iPWatm.exp_atm_model(:,2);
        H     = UW.iPWatm.exp_atm_model(:,3);
    end
end
