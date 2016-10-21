%   dubins calculates an interpolated dubins cureve between two points q0 and
%   q1 with circles of radius r at the inputed stepSize.
%
%   q0 = [x1 (1x1), y1 (1x1), theta1 (1x1)];
%   q1 = [x2 (1x1), y2 (1x1), theta2 (1x1)];
%   r  = (1x1);
%   stepSize = (1x1);
%
%   states = [x;y;theta] (3xn) :  n is deteremined within the code but is a
%                               minimum of 1
%   len = path length
%
%   The original code is from https://github.com/AndrewWalker/Dubins-Curves
function [states, len] = dubins(q0, q1, r, stepSize)
try
  temp = pwd;
  cd(fileparts(mfilename('fullpath')));
  mex dubins.cpp
  cd(temp);
catch
  cd(temp);
end
[states, len] = dubins(q0, q1, r, stepSize);
end

