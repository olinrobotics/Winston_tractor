%% Compute the Greenwich Sideral time
% Earth angular velocity is expressed in deg/min
% The Universal Time UT1 is expressed in minutes
%
% INPUTS
% T = Julian centuries
%
% Universal Time 1:
% hour
% minute
% second 
%
% OUTPUTS
% GST = Greenwich Sideral Time [rad]
%
function GST = G_S_T (T, hour, minute, second)

% Greenwich Sidereal Time in minutes at UT = 0
GST_00 = 100.4606184 + 36000.77005361*T + 0.00038793*T^2 - (2.6*1e-8)*T^3;
% Take GST within 360 degrees
GST_00_deg = mod(GST_00,360);
% UT1 time in minutes
UT1_m = hour*60 + minute + second/60;
GST_deg = GST_00_deg + UW.iPlanet.w_E*UT1_m;

GST = GST_deg * pi/180;