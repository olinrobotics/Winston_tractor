close('all');
clear('classes');

latD = 0.0;
lonD = 0.0;
altF = 300000.0;

% latD = 37.6188172; % SFO
% lonD =  -122.375429-0.005; % SFO
% latD = 40.758896; % NYC
% lonD = -73.985130; % NYC
% altF = 500000.0;

aircraft = {'CartBall'};
callsign = {'N00001'};

for n = 1:numel(callsign)
  port{n} = FlightGear.Base.nextPort(FlightGear.Config.multiPortRange); %#ok grows in loop
  target(n) = FlightGear.Target(port{n}, aircraft{n}, callsign{n}, latD, lonD, altF); %#ok grows in loop
end
camera = FlightGear.Camera(port, latD, lonD, altF);
fprintf('Waiting for FlightGear to start');
while(camera.isBusy()||target(n).isBusy())
  pause(1);
  fprintf('.');
end
fprintf('\n');

target(1).setLLARPY(latD, lonD, altF, 0, 0, 0);
camera.setLLARPY(latD-0.0001, lonD, altF, 0, 0, 0);
