classdef OCDriver < Msg.App & Msg.Cmd & Msg.Time & Msg.Log
  methods (Access = public)
    function this = OCDriver()
      cfg = JSONRead('guard.json');
      this@Msg.App(cfg.ownID, cfg.fastTick, cfg.ctrlTick);
      this@Msg.Cmd(cfg.ackPeriod, cfg.timeWarp);
      this@Msg.Time(cfg.timeSourceID, cfg.timeWarp);
      this@Msg.Log();  
      vMax = OCDynamics.vss(OCDynamics.uSpeedMin);
      vLow = OCDynamics.vss(OCDynamics.uSpeedLow);
      this.maxSpeed = vMax*OCPlanner.relax+vLow*(1.0-OCPlanner.relax);
      this.lowSpeed = vLow*OCPlanner.relax+vMax*(1.0-OCPlanner.relax);
    
      this.cfg = cfg;
      this.own = [];
      this.way = [];
      this.ready = false;
      this.ownTopic = Msg.Proto.topic('nav.FusedState', cfg.ownID);
      this.wayTopic = Msg.Proto.topic('nav.Waystates', cfg.ownID);
      this.uTurnDefault = OCDynamics.kssInv(0);
      this.uSpeedDefault = OCDynamics.vssInv(0);
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
        maxSpeed = 4;
      if(isempty(inbox))
        done = true;
        if(this.ready)
          N = this.way.getTimeSCount();
          if(N>0)
            % TODO: check ownship sigmas and set controls accordingly
            time = this.getTime();
            timeC = time+1.2;
            
            % if time is earlier than the first waypoint
            if(timeC<this.way.getTimeS(0)) % 0-based
              v = this.way.getForwardRateMPS(0); % 0-based
              w = this.way.getYawRateRPS(0); % 0-based
              if(abs(v)<eps)
                k = 0.0;
              else
                k = w/v;
              end
              
            % if time is later than or equal to the last waypoint  
            elseif(timeC>=this.way.getTimeS(N-1)) % 0-based
              v = 0.0;
              k = 0.0;
              
            % else time is between waypoints
            else
              % 0-based
              for nB = 1:(N-1)
                if(timeC<this.way.getTimeS(nB))
                  break;
                end
              end
              nA = nB-1;
            
              timeDeltaOwn = this.own.getTimeDeltaS();
              timeOwn = this.own.getTimeS()
              yawOwn = this.own.getYawR();
              latOwn = this.own.getLatR();
              lonOwn = this.own.getLonR();
              speedOwn = this.own.getForwardDeltaM()/timeDeltaOwn;
              yawRateOwn = this.own.getYawDeltaR()/timeDeltaOwn;
              
              timeA = this.way.getTimeS(nA)
              
              yawA = this.way.getYawR(nA)
              latA = this.way.getLatR(nA);
              lonA = this.way.getLonR(nA);
              speedA = this.way.getForwardRateMPS(nA)
              yawRateA = this.way.getYawRateRPS(nA)
              timeB = this.way.getTimeS(nB);
              yawB = this.way.getYawR(nB);
              latB = this.way.getLatR(nB);
              lonB = this.way.getLonR(nB);
              speedB = this.way.getForwardRateMPS(nB)
              yawRateB = this.way.getYawRateRPS(nB);
              
              if(isempty(this.rLatM))
                this.rLatM = earth.WGS84.radiusOfCurvature(latOwn);
                this.rLonM = cos(earth.WGS84.geodeticToGeocentric(latOwn))*earth.WGS84.geodeticRadius(latOwn);
              end
              
              %Local approximation of the way point in between two
              %waypoints. 
              latTarget = (latA+latB)/2;
              lonTarget = (lonA+lonB)/2;
              x(1) = latOwn*this.rLatM;
              y(1) = lonOwn*this.rLonM;;
              x(2) = latA*this.rLatM;
              y(2) = lonA*this.rLonM;
              x(3) = latOwn*this.rLatM;
              y(3) = lonOwn*this.rLonM;;
              
              
              
              northB = (latB-latOwn)*this.rLatM;
              eastB = (lonB-lonOwn)*this.rLonM;
              
              angularWaypointDistance = (((latB-latOwn)*this.rLatM)^2 + ((lonB-lonOwn)*this.rLonM)^2)^(1/2)
              
              
                      
              
              
              %The atan2(1,6371000)/pi*180 corresponds to a look ahead
              %angular displacement. The 1 that is an argument for atan2
              %corresponds to a 1 meter look ahead distance. There are
              %probably better ways of handling this. 
              
              %%Find Closest Point on Line also calculates look ahead
              %%point. xxx,yyy correspond to a point ahead of the tractor
              %%in the correct direction. 
              northOwn = 0.0;
              eastOwn = 0.0;
              northA = (latA-latOwn)*this.rLatM;
              eastA = (lonA-lonOwn)*this.rLonM;
              northB = (latB-latOwn)*this.rLatM;
              eastB = (lonB-lonOwn)*this.rLonM;
              northRateOwn = speedOwn*cos(yawOwn);
              eastRateOwn = speedOwn*sin(yawOwn);
              northRateA = speedA*cos(yawA);
              eastRateA = speedA*sin(yawA);
              northRateB = speedB*cos(yawB);
              eastRateB = speedB*sin(yawB);

              alpha = (timeC-timeB)/(timeB-timeA);
              speedC = speedA+alpha*(speedB-speedA);
              northC = northA+alpha*(northB-northA);
              eastC = eastA+alpha*(eastB-eastA);
              yawRateC = yawRateA+alpha*(yawRateB-yawRateA);
              northRateC = northRateA+alpha*(northRateB-northRateA);
              eastRateC = eastRateA+alpha*(eastRateB-eastRateA);
              yawC = atan2(eastRateC, northRateC);
              
              rightC = -northC*sin(yawC)+eastC*cos(yawC);
              yawC = atan2(eastRateC, northRateC);
              
              [xx, yy, xxx,yyy] = findClosestPointOnLine(speedC,x,y);
              %Calculate heading determines the direction that the tractor
              %wants to go towards. -> In the straight line to the waypoint
              heading = calculateHeading(xxx,yyy,latOwn*this.rLatM,lonOwn*this.rLonM)*pi/180;
              %Above code assumes yaw from 0 -2*pi. For convenience(hence,
              %probably will need to be changed in future) we shifted
              %yawOwn Up to fit in said range. 
              if(yawOwn<0)
                 yawOwn = yawOwn+2*pi;
              end
              %Our condition check for when desired heading resets back to
              %zero while current heading has not hit two pi. If this is
              %not done, then the heading will invert away from the actual.
              %i.e. instead of it continuing to turn right, it'll turn
              %left. 
              headingDiff= (heading-yawOwn)

              northOwn = 0.0;
              eastOwn = 0.0;
              northA = (latA-latOwn)*this.rLatM;
              eastA = (lonA-lonOwn)*this.rLonM;
              northB = (latB-latOwn)*this.rLatM;
              eastB = (lonB-lonOwn)*this.rLonM;
              northRateOwn = speedOwn*cos(yawOwn);
              eastRateOwn = speedOwn*sin(yawOwn);
              northRateA = speedA*cos(yawA);
              eastRateA = speedA*sin(yawA);
              northRateB = speedB*cos(yawB);
              eastRateB = speedB*sin(yawB);

              alpha = (timeC-timeB)/(timeB-timeA);
              speedC = speedA+alpha*(speedB-speedA);
              actualSpeedC = speedC;
              speedC = max(speedC, this.lowSpeed);
              northC = northA+alpha*(northB-northA);
              eastC = eastA+alpha*(eastB-eastA);
              yawRateC = yawRateA+alpha*(yawRateB-yawRateA);
              northRateC = northRateA+alpha*(northRateB-northRateA);
              eastRateC = eastRateA+alpha*(eastRateB-eastRateA);
              yawC = atan2(eastRateC, northRateC);
              
              rightC = -northC*sin(yawC)+eastC*cos(yawC);
              yawC = atan2(eastRateC, northRateC);
              
              
              
              headingDiff= (heading-yawOwn);
              headingDiff2= (heading-yawC);
              if(yawOwn>pi &&yawOwn<2*pi  && (heading<pi))
                  headingDiff= -diff(unwrap([heading, yawOwn]));
                  headingDiff2 = -diff(unwrap([heading, yawC]));
              end
              
              if(heading>pi &&heading<2*pi  && (yawOwn<pi))
                  headingDiff= -diff(unwrap([heading, yawOwn]));
                  headingDiff2 = -diff(unwrap([heading, yawC]));

              end
              %Our calculation of the difference in heading -> yawErr
              %basically. 
              
              
              %Setting yawErr
              %fprintf('yawErr=%f rightErr=%f\n', yawErr, rightErr);
              
              %Basically, we are adjusting a simple proportional control
              %w.r.t. the angular distance we still are away from the
              %point. We use the base distance of .055 meters in the atan
              %calculation as a following distance behind waypoint A, and
              %the optimum speed is the waypoint speed. 
              
              speedDesired = 1.*(angularWaypointDistance)/10 + speedC;
              
              if(angularWaypointDistance<5)
                  speedDesired = speedC*1.2;
              end

              if(angularWaypointDistance<3)
                  speedDesired = speedC*1.2;
              end
              if(angularWaypointDistance<1.5)
                  speedDesired = speedC*1.1;
              end
              if(angularWaypointDistance<1)
                  speedDesired = speedC*1.05;
              end
              
              if(angularWaypointDistance<.75)
                  speedDesired = speedC*1.025;
              end
              if(angularWaypointDistance<(.25*2))
                  speedDesired = speedC*(1+angularWaypointDistance/100)
              end
              
              if(angularWaypointDistance<(.25))
                  speedDesired = speedC;
                  display('\n\n\n\n\n\n\n\n\n\n')
              end
              %We are capping the speed at 4 mps for now. 
              if(speedDesired > maxSpeed)
                  speedDesired = maxSpeed;
              end
              
              distancePercent = angularWaypointDistance/.5;
              if (distancePercent > 1) 
                 distancePercent = 1;
               
              elseif (distancePercent<0)
                  distancePercent = 0;
                  
              end
              distancesign = cross([latA-latOwn, lonA-lonOwn,0], [latB-latA, lonB-lonA, 0]);
              
              distance = .035*sign(distancesign(3))*angularWaypointDistance;
              
              if(abs(distance) > yawRateC)
                  distance = sign(distance) * yawRateC;
              end
                        vehicleLocalCoord = [cos(yawOwn), -sin(yawOwn), 0; 
                                          sin(yawOwn), cos(yawOwn), 0;
                                          0, 0 , 0] *[latOwn*this.rLatM; -lonOwn*this.rLonM; 1];
              wayPointLocalCoord = [cos(yawOwn), -sin(yawOwn), -vehicleLocalCoord(1); 
                                          sin(yawOwn), cos(yawOwn), -vehicleLocalCoord(2);
                                          0, 0 , 0] * [latA*this.rLatM; -lonA*this.rLonM; 1]
              
              
              if(abs(wayPointLocalCoord(1))<(.25*4))
                  speedDesired = speedC;
              end
              
              if(abs(wayPointLocalCoord(1))<.25)
                 speedDesired = 0; 
              end
              yawErr = headingDiff/2 + yawRateC - wayPointLocalCoord(2)*.07;
              
              %speedDesired = 1.*(wayPointLocalCoord(1))/10 + speedC;
              
              v = speedDesired
              %For closer relation to tractor code, we just set turn radius
              %desired to yawErr. Should probably shift at some point. 
              w = yawErr; %yawRateC+0.4*sat(yawErr, pi/16.0)+0.1*sat(rightErr, 1.0);
              if(abs(v)<eps)
                k = 0.0;
              else
                k = w/v
                if(v<speedC*1.25)
                    k = w/speedC                    
                end
              end
            end
            
            uTurn = OCDynamics.kssInv(k);
            uSpeed = OCDynamics.vssInv(v);
            this.sendCtrl(uTurn, uSpeed);
            done = false;
          end
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
    maxSpeed
    lowSpeed
  end

  methods (Access = private)
    function processInbox(this, inbox)
      [type, ~, pb] = Msg.Proto.unpack(inbox);
      switch(type)
        case 'nav.FusedState'
          this.own = pb;
        case 'nav.Waystates'
          this.way = pb;
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
