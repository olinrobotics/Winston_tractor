%% Aerodynamic Forces and Torques Model
% Aerodynamic forces acting on the spacecraft can be computed in the body
% frame as $F_{aero} = -\frac{1}{2} \rho A C_d V^2$, where $\rho$ is the
% atmosphere's density, $A$ is the cross sectional area matrix, $C_d$ is
% the drag coefficient and $V^2$ is the velocity vector in the body frame.
%
% Torques can be computed as $T_{aero} = F_{aero} \times CoP$ ,where CoP is
% the location of the center of pressure with respect to the Center Of
% Gravity (CoG).
classdef iAero < handle
  properties (Constant = true, GetAccess = public)
    C_drag = [2.2;2.2;2.2];
    
    ax=1;
    ay=UW.iAero.ax;
    az=UW.iAero.ax;
    A_drag = diag([UW.iAero.ax, UW.iAero.ay, UW.iAero.az]);
    
    CoP = [1;0;0];
  end
end
