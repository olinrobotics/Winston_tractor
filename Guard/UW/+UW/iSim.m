%% Init Test_dyn

classdef iSim < handle
    properties (Constant = true, GetAccess = public)
        %% Start Simulation
        Ts = 1; % sample time
        T_stop = 5710; % slightly less than one orbit
        k_s = 1.0;
    end
end