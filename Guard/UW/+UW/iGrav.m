%% Earth's Gravity Model
% This script initializes the gravity acceleration for a small body 
% orbiting the Earth taking in account for perturbations due to the
% oblateness of the planet.

classdef iGrav < handle
    properties (Constant = true, GetAccess = public)
        % Gravity zonal harmonic coefficients
        J2 = 1082.629e-6;
        J2_aux = 3/2*UW.iGrav.J2*UW.iPlanet.mu*UW.iPlanet.r_E^2;
        
        J3 = -2.5326e-6;
        J3_aux = 0.5*UW.iGrav.J3*UW.iPlanet.mu*UW.iPlanet.r_E^3;       
    end
end
