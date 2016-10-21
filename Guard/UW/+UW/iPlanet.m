%% Planet common parameters
% this Earth model is based on WGS-84
classdef iPlanet < handle
    properties (Constant = true, GetAccess = public)
        % Planet's geometry related constants
        r_E = 6378137;   % [m] % Earth's equatorial radius
        f = 1/298.257223563; % Earth's oblatenes flattening factor
        e2 = UW.iPlanet.f*(2 - UW.iPlanet.f); % e^2
        r_Ep = UW.iPlanet.r_E*sqrt(1 - UW.iPlanet.e2) % [m] Earth's polar radius
        l = UW.iPlanet.e2/2;
        l2 = UW.iPlanet.l^2; % l^2
        
        % Planet's mass related Constants
        m_E = 5.9723e24; % [Kg] % Earth's mass
        G = 6.67408e-11; % [m^3 Kg^-1 s-2] % Universal Earth's gravitaitonal constant
        w_E = 0.25068447733746215; % [deg/min] Earth's angular velocity
        mu = UW.iPlanet.G*UW.iPlanet.m_E; % Earth's gravitaitonal parameter
        
    end
end