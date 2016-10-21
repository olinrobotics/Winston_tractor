% An application that produces waypoints for a vehicle to follow.
classdef OCPlanner < Msg.App & Msg.Log
  properties (Constant = true, GetAccess = public)
    algorithm = 'circle';
    missionAppID = 'ARDAutonomy';
    relax = 0.8; % relaxation of dynamic constraints
  end
  
  properties (GetAccess = private, SetAccess = private)
    cfg
    own
    target
    behavior
    minRadius
    maxSpeed
    lowSpeed
    spacing
    vRate
    rLatM
    rLonM
    approach
  end
  
  methods (Access = public)
    function this = OCPlanner()
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), cfg.fastTick, cfg.slowTick);
      this = this@Msg.Log();
      this.cfg = cfg;
      this.minRadius = 1.0/(OCDynamics.kss(OCDynamics.uTurnMin)*OCPlanner.relax);
      vMax = OCDynamics.vss(OCDynamics.uSpeedMin);
      vLow = OCDynamics.vss(OCDynamics.uSpeedLow);
      this.maxSpeed = vMax*OCPlanner.relax+vLow*(1.0-OCPlanner.relax);
      this.lowSpeed = vLow*OCPlanner.relax+vMax*(1.0-OCPlanner.relax);
      this.spacing = pi*this.minRadius/8.0; % 16 segments around the minimum radius circle
      this.vRate = OCDynamics.vRateMax*OCPlanner.relax;
      this.approach = [];
    end
    
    function sub = topics(this)
      sub{1, 1} = Msg.Proto.topic('nav.FusedState', this.cfg.ownID);
      sub{2, 1} = Msg.Proto.topic('nav.FusedState', this.cfg.targetID);
      sub{3, 1} = Msg.Proto.topic('nav.Mission', OCPlanner.missionAppID);
    end
    
    function process(this, inbox)
      % TODO: eventually should check ownship sigmas and replan accordingly
      if(~isempty(inbox))
        [topic, id, pb] = Msg.Proto.unpack(inbox);
        switch(topic)
          case 'nav.FusedState'
            if(strcmp(id, this.cfg.ownID))
              this.own = pb;
            elseif(strcmp(id, this.cfg.targetID))
              this.target = pb;
            end
          case 'nav.Mission'
            this.behavior = pbGetBehavior(pb);
        end
      else
        if(~isempty(this.own)&&~isempty(this.target))
          switch(OCPlanner.algorithm)
            case 'circle'
              timeA = this.own.getTimeS();
              timeDeltaA = this.own.getTimeDeltaS();
              yawA = this.own.getYawR();
              latA = this.own.getLatR();
              lonA = this.own.getLonR();
              yawRateA = this.own.getYawDeltaR()/timeDeltaA;
              forwardRateA = this.own.getForwardDeltaM()/timeDeltaA;
              rightRateA = this.own.getRightDeltaM()/timeDeltaA;
              northRateA = forwardRateA*cos(yawA)-rightRateA*sin(yawA);
              eastRateA = forwardRateA*sin(yawA)+rightRateA*cos(yawA);
              speedA = sqrt(forwardRateA*forwardRateA+rightRateA*rightRateA);
              
              switch(uint8(this.behavior))
                case uint8(Behavior.APPROACH)
                  if(~isempty(this.approach))
                    time = this.approach.time-this.approach.time(end)+timeA+2.0*this.cfg.tDanger;
                    yaw = this.approach.yaw;
                    lat = this.approach.lat;
                    lon = this.approach.lon;
                    yawRate = this.approach.yawRate;
                    speed = this.approach.speed;
                  else
                    
                    timeB = this.target.getTimeS();
                    timeDeltaB = this.target.getTimeDeltaS();
                    yawB = this.target.getYawR();
                    latB = this.target.getLatR();
                    lonB = this.target.getLonR();
                    yawRateB = this.target.getYawDeltaR()/timeDeltaB;
                    forwardRateB = this.target.getForwardDeltaM()/timeDeltaB;
                    rightRateB = this.own.getRightDeltaM()/timeDeltaB;
                    northRateB = forwardRateB*cos(yawB)-rightRateB*sin(yawB);
                    eastRateB = forwardRateB*sin(yawB)+rightRateB*cos(yawB);
                    speedB = sqrt(forwardRateB*forwardRateB+rightRateB*rightRateB);
                    
                    if(isempty(this.rLatM))
                      this.rLatM = earth.WGS84.radiusOfCurvature(latB);
                      this.rLonM = cos(earth.WGS84.geodeticToGeocentric(latB))*earth.WGS84.geodeticRadius(latB);
                    end
                    
                    % plan relative to target
                    timeAB = timeB-timeA;
                    latA = latA+northRateA*timeAB/this.rLatM;
                    lonA = lonA+eastRateA*timeAB/this.rLonM;
                    yawA = math.Rotation.wrapToPI(yawA+yawRateA*timeAB);
                    timeA = timeB;
                    northA = (latA-latB)*this.rLatM;
                    eastA = (lonA-lonB)*this.rLonM;
                    northB = 0.0;
                    eastB = 0.0;
                    
                    dtStep = 1.0;
                    dtMax = 2.0*this.cfg.tDanger;
                    dtMin = -2.0;
                    trailSpeed = max(speedB, this.lowSpeed);
                    if(trailSpeed>speedB)
                      dtDecel = (trailSpeed-speedB)/this.vRate;
                      dsDecel = speedB+0.5*this.vRate*dtDecel*dtDecel;
                    else
                      dtDecel = dtStep;
                      dsDecel = trailSpeed*dtStep;
                    end
                    dtTrail = fliplr(0.0:-dtStep:dtMin);
                    dt = [dtTrail-dtDecel, (0.0:dtStep:dtMax)];
                    ds = [dtTrail*trailSpeed-dsDecel, (0.0:dtStep:dtMax)*speedB];
                    
                    K = numel(dt);
                    
                    if(abs(speedB)>eps)
                      curvature = yawRateB/speedB;
                    else
                      curvature = 0.0;
                    end
                    [forward, right, yaw] = evalCircleS(speedB, yawRateB, ds);
                    yaw = math.Rotation.wrapToPI(yawB+yaw);
                    north = forward.*cos(yawB)-right.*sin(yawB);
                    east = forward.*sin(yawB)+right.*cos(yawB);
                    speed = [repmat(trailSpeed, 1, numel(dtTrail)), repmat(speedB, 1, K-numel(dtTrail))];
                    yawRate = curvature*speed;
                    time = timeB+dt;
                    
                    % prepend dubins path
                    [time, yaw, north, east, yawRate, speed] = this.prependDubins(yawA, northA, eastA,...
                      time, yaw, north, east, yawRate, speed);
                    
                    % convert back to lat-lon
                    lat = latB+north/this.rLatM;
                    lon = lonB+east/this.rLonM;
                    
                    this.approach.time = time;
                    this.approach.yaw = yaw;
                    this.approach.lat = lat;
                    this.approach.lon = lon;
                    this.approach.yawRate = yawRate;
                    this.approach.speed = speed;
                  end
                  
                otherwise % Behavior.LOITER
                  time = timeA;
                  yaw = yawA;
                  lat = latA;
                  lon = lonA;
                  yawRate = yawRateA;
                  speed = speedA;
              end
          end
          
          % construct output
          pb = nav.WaystatesBuilder();
          for k = 1:numel(time)
            addState(pb, time(k), yaw(k), lat(k), lon(k), yawRate(k), speed(k));
          end
          this.send(Msg.Proto.pack('nav.Waystates', this.cfg.ownID, pb));
        end
      end
    end
    
    function [time, yaw, north, east, yawRate, speed] = prependDubins(this, yawA, northA, eastA,...
        time, yaw, north, east, yawRate, speed)
      if(sqrt(northA*northA+eastA*eastA)>2.0*this.spacing)
        [path, len] = dubins([northA, eastA, yawA], [north(1), east(1), yaw(1)], 2.0*this.minRadius, this.spacing);
        K = size(path, 2);
        if(K>=2)
          path = path(:, 1:(end-1)); % remove last point
          K = K-1;
          
          % extract elements
          northD = path(1, :);
          eastD = path(2, :);
          yawD = math.Rotation.wrapToPI(path(3, :));
          
          % plan speed profile
          speedD = repmat(speed(1), 1, K);
          
          % plan time profile
          timeD = time(1)-fliplr(1:K)*(len/K)/speed(1);
          
          % plan rotation rate profile
          yawRateD = gradient(unwrap(yawD))./gradient(timeD);
          
          % prepend
          time = [timeD, time];
          yaw = [yawD, yaw];
          north = [northD, north];
          east = [eastD, east];
          yawRate = [yawRateD, yawRate];
          speed = [speedD, speed];
        end
      end
    end
  end
end


function [x, y, p] = evalCircleT(v0, pd0, t)
[M, N] = size(t);
if(abs(pd0)<=eps)
  r0 = inf;
else
  r0 = v0/pd0;
end
absr0 = abs(r0);
if(absr0<=eps)
  p = zeros(M, N);
  x = zeros(M, N);
  y = zeros(M, N);
elseif(absr0>=(1.0/eps))
  p = zeros(M, N);
  x = t*v0;
  y = zeros(M, N);
else
  p = t*pd0;
  x = r0*sin(p);
  y = r0*(1.0-cos(p));
end
end


function [x, y, p] = evalCircleS(v0, pd0, s)
[M, N] = size(s);
if(abs(pd0)<=eps)
  r0 = inf;
else
  r0 = v0/pd0;
end
absr0 = abs(r0);
if(absr0<=eps)
  p = zeros(M, N);
  x = zeros(M, N);
  y = zeros(M, N);
elseif(absr0>=(1.0/eps))
  p = zeros(M, N);
  x = s;
  y = zeros(M, N);
else
  p = s/r0;
  x = r0*sin(p);
  y = r0*(1.0-cos(p));
end
end


function addState(pb, timeS, yawR, latR, lonR, yawRateRPS, speedMPS)
pb.addTimeS(timeS);
pb.addRollR(0.0);
pb.addPitchR(0.0);
pb.addYawR(yawR);
pb.addLatR(latR);
pb.addLonR(lonR);
pb.addAltM(0.0);
pb.addRollRateRPS(0.0);
pb.addPitchRateRPS(0.0);
pb.addYawRateRPS(yawRateRPS);
pb.addForwardRateMPS(speedMPS);
pb.addRightRateMPS(0.0);
pb.addDownRateMPS(0.0);
end
