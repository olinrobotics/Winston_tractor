function r_ECI_v_ECI = orb2ECI(a,e,i,OM,w,th,mu)

p = a*(1-e^2); % semilatus rectum

r = p/(1+e*cos(th)); % orbital radius
% orbital radius components
rx = r*cos(th);
ry = r*sin(th);
% orbital radius vector in orbital frame
r_orb = [rx;ry;0];

v = sqrt(mu/p); % orbital velocity
% orbital velocity components
vx = -v*sin(th);
vy = v*(e + cos(th));
% orbital velocity vector in orbital frame
v_orb = [vx;vy;0];

% Rotation matrices between orbital and ECI frames (3 - 1 - 3 rotation)

Rw = [ cos(w) sin(w) 0;
      -sin(w) cos(w) 0;
       0      0      1];
Ri = [ 1   0     0; 
       0  cos(i) sin(i);
       0 -sin(i) cos(i)];
   
R_OM = [ cos(OM) sin(OM) 0;
        -sin(OM) cos(OM) 0;
         0       0       1];
     
r_ECI = (Rw*Ri*R_OM)' * r_orb;  
v_ECI = (Rw*Ri*R_OM)' * v_orb;

r_ECI_v_ECI = [r_ECI;v_ECI];
end