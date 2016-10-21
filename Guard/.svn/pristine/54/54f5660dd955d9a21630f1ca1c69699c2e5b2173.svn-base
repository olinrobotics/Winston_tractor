%% Initial Conditions
% This script sets the initial position and velocity from the five
% classical elements
classdef iPVA < handle
    properties (Constant = true, GetAccess = public)
        %% Utility
        d2r = pi/180; % degrees to radians
        r2d = 180/pi; % radians to degrees
        
        %% The five classical elements are:
        % a = semi majior axis
        % e = eccentricity
        % i = inclination
        % OMEGA = right ascension of the right ascending node (OM)
        % omega = argument of the perigee (w)
        % M = mean anomaly
        
        %Hubble orbit
        a = UW.iPlanet.r_E + (539e3 + 543e3)/2; % (perigee + apogee)/2 [m]
        e = 0.0002567;
        i = 28.4698*UW.iPVA.d2r; % [rad]
        OM = 89.6995*UW.iPVA.d2r; % [rad]
        w = 255.2252*UW.iPVA.d2r; % [rad]
        M = 249.9884*UW.iPVA.d2r; % [rad]
        
        %% Eccentric Anomaly E and true anomaly theta
        Eth = UW.E_th(UW.iPVA.e,UW.iPVA.M);
        E = UW.iPVA.Eth(1);
        th = UW.iPVA.Eth(2);
        % initial position and velocity in ECI frame from orbital data
        r_ECI_v_ECI = UW.orb2ECI(UW.iPVA.a, UW.iPVA.e, UW.iPVA.i, UW.iPVA.OM, UW.iPVA.w, UW.iPVA.th, UW.iPlanet.mu); % (perifocal to ECI)
        
        %% initial conditions
        % i_pos = [(r_E + h);0;0]; % ECI frame
        % i_vel = [0;7668;0]; % ECI frame
        i_pos = UW.iPVA.r_ECI_v_ECI(1:3);
        i_vel = UW.iPVA.r_ECI_v_ECI(4:6);
        i_q = [0;0;0;1]; % body frame
        i_rates = [0;0;0]; % body frame
        X0 = [UW.iPVA.i_pos; UW.iPVA.i_vel; UW.iPVA.i_q; UW.iPVA.i_rates];
    end
end