%% Mass Evolution Model
% This script initializes the "Mass and Inertia" subsystem
classdef iMass < handle
    properties (Constant = true, GetAccess = public)
        m_wet  = 919.200; %[Kg]
        m_dry  = 405.300; %[Kg]
        m_fuel = UW.iMass.m_wet - UW.iMass.m_dry;
        
        %% Mass Evolution
        % For a rocket engine the mass evolution can be modeled as
        % $\dot{m} = \frac{F_{rkt}}{g_0 I_{SP}}$, where $m$ is the mass of the
        % spacecraft, F_{rkt} is the thrust norm generated by the engine, $g_0$ is
        % the Earth reference gravity acceleration, and $I_{SP}$ is the engine's
        % specific impulse.
        
        % reference gravity
        g0 = 9.80665; %m/s^2;
        
        %specific impulse
        Isp = 360; %[s]
        
        %% Inertia ang CoG
        % These parameters are modeled here via a lookup table.
        
        % location of the Center of Gravity (w.r.t. the geometrical reference frame) as a function of the
        % total mass
        % column 1: mass [Kg]
        % column 2: xG [m]
        % column 3: yG [m]
        % column 4: zG [m]
        CoG_table = [ 405.300  1.424  0  0;
                      456.690  1.345  0  0;
                      508.080  1.285  0  0;
                      559.470  1.240  0  0;
                      610.860  1.206  0  0;
                      662.250  1.181  0  0;
                      713.640  1.163  0  0;
                      765.030  1.149  0  0;
                      816.420  1.140  0  0;
                      867.810  1.135  0  0;
                      919.200  1.132  0  0 ];
        
        % Inertia Matrix (in body frame) as a function of the total mass
        % column 1: mass
        % column 2: Ixx
        % column 3: Iyy
        % column 4: Izz
        % column 5: Ixy
        % column 6: Ixz
        % column 7: Iyz
        Inertia_Matrix_Table = [ 405.300  83.576   139.937  142.147  0  0  0;
                                 456.690  108.265  175.317  177.527  0  0  0;
                                 508.080  132.955  203.684  205.894  0  0  0;
                                 559.470  157.645  227.125  229.335  0  0  0;
                                 610.860  182.334  247.041  249.251  0  0  0;
                                 662.250  207.024  264.411  266.621  0  0  0;
                                 713.640  231.714  279.946  282.156  0  0  0;
                                 765.030  256.403  294.176  296.386  0  0  0;
                                 816.420  281.093  307.510  309.720  0  0  0;
                                 867.810  305.782  320.272  322.482  0  0  0;
                                 919.200  330.472  332.721  334.931  0  0  0 ];
        
        %split the inertia for lookup tables
        m_idx  = UW.iMass.Inertia_Matrix_Table(:,1);
        GoG_m  = UW.iMass.CoG_table(:,2);
        I_xx_m = UW.iMass.Inertia_Matrix_Table(:,2);
        I_yy_m = UW.iMass.Inertia_Matrix_Table(:,3);
        I_zz_m = UW.iMass.Inertia_Matrix_Table(:,4);
        
        %% Fuel Sloshing
        % Modeled here as a spring - mass - damper equivalent, assuming spherical
        % tanks and conic baffles $m_L$ is the total mass in the tank, $\tau$ is
        % the filling ratio, $\alpha_s = \lambda(0.5)$ is a tank parameter.
        % $k_s$ is the spring stiffness and $\beta_s$ is the damping. The state of
        % the system is the position and velocity of the sloshing mass
        % $mathbf{x}_s = [x_s;\dot{x}_s]$, while the input $\gamma_1$ is the
        % acceleration of m1 with respect to the spacecraft body frame
        % here the natural frequency and damping ranges are
        % $\omega_0 = [0.01; 0.04] [Hz]$ for $\tau = 0.5$ and
        % $\beta_s \in [0.16; 0.5] [s^{-1}]$ respectively.
        
        % location of the Fuel Tanks (in body frame)
        Fuel_Tank_1 = [1.4 -0.85 0.85];
        Fuel_Tank_2 = [1.4  0.85 0.85];
        n_tanks = 2;
        
        alpha_s = 0.62;
        m_fuel_T1 = UW.iMass.m_fuel/UW.iMass.n_tanks; % [Kg] %assuming fuel is equally divided between tanks
        om_0_2 = 6.25e-4; % w_0^2= k_s/m1
        beta_s = 0.33;
        % % Continuos time State Space representation for one axis
        % a_s_x = [0 1; -om_0_2 -beta_s/m1];
        % b_s_x = [0;1];
        % c_s_x = [om_0_2*m1 beta_s];
        % d_s_x = 0;
    end
end
