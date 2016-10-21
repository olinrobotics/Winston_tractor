% An application that remotely controls multiple vehicles, driving them toward desired states.
classdef ARDDriver < Msg.App & Msg.Cmd & Msg.Time & Msg.Log
  properties (Constant = true, GetAccess = public)
    lateralTolerance = 0.5;
  end
  
  methods (Access = public)
    function this = ARDDriver()
      cfg = JSONRead('guard.json');
      this@Msg.App(cfg.ownID, cfg.fastTick, cfg.ctrlTick);
      this@Msg.Cmd(cfg.ackPeriod, cfg.timeWarp);
      this@Msg.Time(cfg.timeSourceID, cfg.timeWarp);
      this@Msg.Log();
      this.cfg = cfg;
      this.own = [];
      this.way = [];
      this.ready = false;
      this.ownTopic = Msg.Proto.topic('nav.FusedState', cfg.ownID);
      this.wayTopic = Msg.Proto.topic('nav.Waystates', cfg.ownID);
      this.uTurnDefault = OCDynamics.kssInv(0);
      this.uSpeedDefault = OCDynamics.vssInv(0);
      this.dtLag = [];
      this.v = 0.0;
      this.k = 0.0;
      this.vMax = OCDynamics.vss(OCDynamics.uSpeedMin);
      this.vMin = OCDynamics.vss(OCDynamics.uSpeedMax);
      this.kMax = OCDynamics.kss(OCDynamics.uTurnMin);
      this.kMin = OCDynamics.kss(OCDynamics.uTurnMax);
      this.vPID = OCPID(cfg.ctrlTick, 0.0, 0.0, 0.0);
      this.kPID = OCPID(cfg.ctrlTick, 0.0, 0.0, 0.0);
    end
    
    function sub = topics(this)
      sub{1, 1} = this.ownTopic;
      sub{2, 1} = this.wayTopic;
    end
    
    function done = init(this)
      this.sendCtrl(this.uTurnDefault, this.uSpeedDefault);
      done = this.isTimeSet();
    end
    
    function idle(this, inbox)
      if(isempty(inbox))
        this.sendCtrl(this.uTurnDefault, this.uSpeedDefault);
      else
        this.processInbox(inbox);
      end
    end
    
    function done = run(this, inbox)
      if(isempty(inbox))
        done = true;
        if(this.ready)
          N = this.way.getTimeSCount(); % there must be at least one waystate for ready to be true
          time = this.getTime(); % current time
          if(isempty(this.dtLag))
            this.dtLag = time-this.way.getTimeS(0);
          end
          timeC = time-this.dtLag;
          
          % search for the waystate interval and target time
          if(N==1)
            nA = 0;
            nB = 0;
            timeA = this.way.getTimeS(nA); % 0-based
            timeB = timeA;
            timeC = timeB;
          
          else
            for nA = 0:(N-2) % 0-based
              nB = nA+1;
              
              % get time at both ends of waystate interval
              timeA = this.way.getTimeS(nA); % 0-based
              timeB = this.way.getTimeS(nB); % 0-based
              
              % if target time is earlier than or equal to the beginning of the interval
              if(timeC<=timeA)
                this.dtLag = max(this.cfg.ctrlTick, time-timeA);
                timeC = time-this.dtLag;
                break; % select this interval
              end
              
              % if target time is later than or equal to the end of the interval
              if(timeC>=timeB)
                continue; % skip this interval
              end
              
              % get minimal state info
              latOwn = this.own.getLatR();
              lonOwn = this.own.getLonR();
              latB = this.way.getLatR(nB);
              lonB = this.way.getLonR(nB);
              
              % compute local coordinates relative to follower
              northB = (latB-latOwn)*this.rLatM;
              eastB = (lonB-lonOwn)*this.rLonM;
              % if the waystate has been achieved
              if(sqrt(northB*northB+eastB*eastB)<ARDDriver.lateralTolerance)
                this.dtLag = max(this.cfg.ctrlTick, time-timeB);
                timeC = time-this.dtLag;
                continue; % skip this interval
              else
                break; % select this interval
              end
            end
          end
          
          %fprintf('dtLag=%f nA=%d timeA=%f timeC=%f timeB=%f\n', this.dtLag, nA, timeA, timeC, timeB);
          
          % if target time is later than or equal to the last waystate
          if(timeC>=this.way.getTimeS(N-1))
            this.v = 0.0;
            this.k = 0.0;
          else
            
            timeOwn = this.own.getTimeS();
            timeDeltaOwn = this.own.getTimeDeltaS();
            yawOwn = this.own.getYawR();
            latOwn = this.own.getLatR();
            lonOwn = this.own.getLonR();
            forwardRateOwn = this.own.getForwardDeltaM()/timeDeltaOwn;
            rightRateOwn = this.own.getRightDeltaM()/timeDeltaOwn;
            yawRateOwn = this.own.getYawDeltaR()/timeDeltaOwn;
            northRateOwn = forwardRateOwn*cos(yawOwn)-rightRateOwn*sin(yawOwn);
            eastRateOwn = forwardRateOwn*sin(yawOwn)+rightRateOwn*cos(yawOwn);
            speedOwn = sqrt(forwardRateOwn*forwardRateOwn+rightRateOwn*rightRateOwn);
            
            % apply prediction to bring own up to date
            timeOC = time-timeOwn;
            latOwn = latOwn+northRateOwn*timeOC/this.rLatM;
            lonOwn = lonOwn+eastRateOwn*timeOC/this.rLonM;
            yawOwn = math.Rotation.wrapToPI(yawOwn+yawRateOwn*timeOC);
            timeOwn = time;
            
            yawA = this.way.getYawR(nA);
            latA = this.way.getLatR(nA);
            lonA = this.way.getLonR(nA);
            forwardRateA = this.way.getForwardRateMPS(nA);
            rightRateA = this.way.getRightRateMPS(nA);
            yawRateA = this.way.getYawRateRPS(nA);
            speedA = sqrt(forwardRateA*forwardRateA+rightRateA*rightRateA);
            
            yawB = this.way.getYawR(nB);
            latB = this.way.getLatR(nB);
            lonB = this.way.getLonR(nB);
            forwardRateB = this.way.getForwardRateMPS(nB);
            rightRateB = this.way.getRightRateMPS(nB);
            yawRateB = this.way.getYawRateRPS(nB);
            speedB = sqrt(forwardRateB*forwardRateB+rightRateB*rightRateB);

            % compute local coordinates of waystate relative to follower
            northA = (latA-latOwn)*this.rLatM;
            eastA = (lonA-lonOwn)*this.rLonM;
            northB = (latB-latOwn)*this.rLatM;
            eastB = (lonB-lonOwn)*this.rLonM;
            
            alpha = (timeC-timeA)/(timeB-timeA);
            speedC = speedA+alpha*(speedB-speedA);
            northC = northA+alpha*(northB-northA);
            eastC = eastA+alpha*(eastB-eastA);
            yawRateC = yawRateA+alpha*(yawRateB-yawRateA);
%             northRateC = northRateA+alpha*(northRateB-northRateA);
%             eastRateC = eastRateA+alpha*(eastRateB-eastRateA);
            yawC = yawA+alpha*diff(unwrap([yawA, yawB])); % same as atan2(eastRateC, northRateC)

            % curvature control law
            rMin = 1.0/this.kMax;
            lookAhead = 0.5*pi*rMin;
            [forwardCD, rightCD, yawCD] = evalCircleS(speedC, yawRateC, lookAhead);
            northD = northC+forwardCD*cos(yawC)-rightCD*sin(yawC);
            eastD = eastC+forwardCD*sin(yawC)+rightCD*cos(yawC);
            forwardOD = northD*cos(yawOwn)+eastD*sin(yawOwn);
            rightOD = -northD*sin(yawOwn)+eastD*cos(yawOwn);
            yawD = math.Rotation.wrapToPI(yawC+yawCD);
            
            den = (forwardOD*forwardOD+rightOD*rightOD);
            if(den>eps)
              curvature = 2.0*rightOD/den;
            else
              curvature = this.k;
            end
            this.kPID.kp = 0.01;
            this.kPID.ki = 0.001;
            this.kPID.kd = 0.0001;
            if(abs(speedC)>eps)
              kC = yawRateC/speedC;
            else
              kC = 0.0;
            end
            this.k = kC+this.kPID.f(curvature);

            % speed control law
            forwardErr = -(northC*(cos(yawC)+cos(yawOwn))+eastC*(sin(yawC)+sin(yawOwn)))/2.0;        
            this.vPID.kp = 0.2;
            this.vPID.ki = 0.001;
            this.vPID.kd = 0.0;
            this.v = speedC-this.vPID.f(sat(forwardErr, 0.5*this.vMax));
          end
          
          uTurn = OCDynamics.kssInv(this.k);
          uSpeed = OCDynamics.vssInv(this.v);
          this.sendCtrl(uTurn, uSpeed);
          done = false;
        end
      else
        this.processInbox(inbox);
        done = ~this.ready;
      end
    end

    function term(this)
      this.sendCtrl(this.uTurnDefault, this.uSpeedDefault);
    end
  end
  
  properties (GetAccess = private, SetAccess = private)
    cfg
    own
    way
    ready
    rLatM
    rLonM
    ownTopic
    wayTopic
    uTurnDefault
    uSpeedDefault
    dtLag
    v
    k
    vMax
    vMin
    kMax
    kMin
    vPID
    kPID
  end

  methods (Access = private)
    function processInbox(this, inbox)
      [type, ~, pb] = Msg.Proto.unpack(inbox);
      switch(type)
        case 'nav.FusedState'
          this.own = pb;
        case 'nav.Waystates'
          N = pb.getTimeSCount();
          if(N>0)
            this.way = pb;
            if(isempty(this.rLatM))
              latR = pb.getLatR(0); % 0-based
              this.rLatM = earth.WGS84.radiusOfCurvature(latR);
              this.rLonM = cos(earth.WGS84.geodeticToGeocentric(latR))*earth.WGS84.geodeticRadius(latR);
            end
          end
      end
      this.ready = ~(isempty(this.own)|isempty(this.way));
    end
    
    function sendCtrl(this, uTurn, uSpeed)
      lvin = nav.LabViewInBuilder();
      ctrl = nav.CtrlBuilder();
      u.turn = int32(uTurn);
      u.speed = int32(uSpeed);
      data = [typecast(u.turn, 'uint8'), typecast(u.speed, 'uint8')];
      lvin.setData(lvin.getData().copyFrom(data));
      this.send(Msg.Proto.pack('nav.LabViewIn', this.cfg.ownID, lvin));
      ctrl.addUInt(u.turn);
      ctrl.addUInt(u.speed);
      this.send(Msg.Proto.pack('nav.Ctrl', this.cfg.ownID, ctrl));
      this.log('uTurn=%d uSpeed=%d', u.turn, u.speed);
    end
  end
end

function x = sat(x, y)
if(x>y)
  x = y;
elseif(x<-y)
  x = -y;
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

% dt = 1.0/str2double(FlightGear.Config.hz);
% if(~isempty(this.x))
%   dx = this.xTarget-this.x-ARDDriver.dIdeal;
%   vDesired = 0.1*dx;
%   f = 0.1*(vDesired-this.v)/dt;
%   this.log('dx=%f;vDesired=%f;f=%f', dx, vDesired, f);
% else
%   f = 0.0;
% end
