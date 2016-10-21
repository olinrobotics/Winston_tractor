% An application that produces waypoints for a vehicle to follow.
classdef UWPlanner < Msg.App & Msg.Log
  properties (Constant = true, GetAccess = public)
    relax = 0.8; % relaxation of dynamic constraints
  end
  
  properties (GetAccess = private, SetAccess = private)
    cfg
    own
    target
  end
  
  methods (Access = public)
    function this = UWPlanner()
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), cfg.fastTick, cfg.slowTick);
      this = this@Msg.Log();
      this.cfg = cfg;
    end
    
    function sub = topics(this)
      sub{1, 1} = Msg.Proto.topic('nav.FusedState', this.cfg.ownID);
      sub{2, 1} = Msg.Proto.topic('nav.FusedState', this.cfg.targetID);
    end
    
    function process(this, inbox)
      if(~isempty(inbox))
        [topic, id, pb] = Msg.Proto.unpack(inbox);
        if(strcmp(topic, 'nav.FusedState'))
          if(strcmp(id, this.cfg.ownID))
            this.own = pb;
          elseif(strcmp(id, this.cfg.targetID))
            this.target = pb;
          end
        end
      else
        if(~isempty(this.own)&&~isempty(this.target))
          % input
          timeS(1) = this.own.getTimeS();
          timeDeltaS(1) = this.own.getTimeDeltaS();
          rollR(1) = this.own.getRollR();
          pitchR(1) = this.own.getPitchR();
          yawR(1) = this.own.getYawR();
          latR(1) = this.own.getLatR();
          lonR(1) = this.own.getLonR();
          altM(1) = this.own.getAltM();
          rollRateRPS(1) = this.own.getRollDeltaR()/timeDeltaS(1);
          pitchRateRPS(1) = this.own.getPitchDeltaR()/timeDeltaS(1);
          yawRateRPS(1) = this.own.getYawDeltaR()/timeDeltaS(1);
          forwardRateMPS(1) = this.own.getForwardDeltaM()/timeDeltaS(1);
          rightRateMPS(1) = this.own.getRightDeltaM()/timeDeltaS(1);
          downRateMPS(1) = this.own.getDownDeltaM()/timeDeltaS(1);
          
          timeS(2) = this.target.getTimeS();
          timeDeltaS(2) = this.target.getTimeDeltaS();
          rollR(2) = this.target.getRollR();
          pitchR(2) = this.target.getPitchR();
          yawR(2) = this.target.getYawR();
          latR(2) = this.target.getLatR();
          lonR(2) = this.target.getLonR();
          altM(2) = this.target.getAltM();
          rollRateRPS(2) = this.target.getRollDeltaR()/timeDeltaS(2);
          pitchRateRPS(2) = this.target.getPitchDeltaR()/timeDeltaS(2);
          yawRateRPS(2) = this.target.getYawDeltaR()/timeDeltaS(2);
          forwardRateMPS(2) = this.target.getForwardDeltaM()/timeDeltaS(2);
          rightRateMPS(2) = this.target.getRightDeltaM()/timeDeltaS(2);
          downRateMPS(2) = this.target.getDownDeltaM()/timeDeltaS(2);
          
          % TODO: INSERT YOUR PLANNER HERE
          timeS(2) = timeS(1)+100.0; % arbitrary closing time for interface illustration only
          
          % output
          pb = nav.WaystatesBuilder();
          for k = 1:numel(timeS)
            addState(pb, timeS(k), rollR(k), pitchR(k), yawR(k), latR(k), lonR(k), altM(k), rollRateRPS(k),...
              pitchRateRPS(k), yawRateRPS(k), forwardRateMPS(k), rightRateMPS(k), downRateMPS(k));
          end
          this.send(Msg.Proto.pack('nav.Waystates', this.cfg.ownID, pb));
        end
      end
    end
  end
end

function addState(pb, timeS, rollR, pitchR, yawR, latR, lonR, altM, rollRateRPS, pitchRateRPS, yawRateRPS,...
  forwardRateMPS, rightRateMPS, downRateMPS)
pb.addTimeS(timeS);
pb.addRollR(rollR);
pb.addPitchR(pitchR);
pb.addYawR(yawR);
pb.addLatR(latR);
pb.addLonR(lonR);
pb.addAltM(altM);
pb.addRollRateRPS(rollRateRPS);
pb.addPitchRateRPS(pitchRateRPS);
pb.addYawRateRPS(yawRateRPS);
pb.addForwardRateMPS(forwardRateMPS);
pb.addRightRateMPS(rightRateMPS);
pb.addDownRateMPS(downRateMPS);
end
