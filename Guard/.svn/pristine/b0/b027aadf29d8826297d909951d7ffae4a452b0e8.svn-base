%% Eccentric Anomaly E and true anomaly theta calculator
%
% The true anomaly is then computed using from the eccentric anomaly
% computed via the Newton-Raphson iterator.
%
% Inputs:
% e = orbit's eccentricity
% M = mean anomaly [rad]
%
% Outputs:
% E_f = eccentric anomaly [rad]
% th = true anomaly [rad]

function E_f_th = E_th(e,M)
keepgoing = 1;
maxiter = 30;
E_tol = 1e-6;
k = 1;

if e < 0.8
    E(k)=M;
else
    E(k)=pi;
end
% all radians
while keepgoing && k<maxiter
    
    E(k+1) = E(k) - (E(k) - e*sin(E(k)) - M)/(1 - e*cos(E(k)));
    
    if abs(E(k+1) - E(k)) >= E_tol
        k = k + 1;
    else
        keepgoing = 0;
    end
end

E_f = E(end);
% E_f_d = E_f * r2d;

% true anomaly THETA

th = atan2((sqrt(1-e^2))*sin(E_f), (cos(E_f) - e));
% th_d = th * r2d;

E_f_th = [E_f;th];

end