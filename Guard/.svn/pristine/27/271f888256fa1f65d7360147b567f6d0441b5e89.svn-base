% An application that remotely controls multiple vehicles, driving them toward desired states.
classdef ARDPlanner < Msg.App & Msg.Time & Msg.Log
  properties (GetAccess = public, Constant = true)
    fiducialScaleM = getfield(JSONRead('guard.json'), 'fiducialScaleM'); % fiducial scale
    hfovR = str2double(FlightGear.Config.hfov)*math.DEGTORAD; % horizontal field of view
    dIdeal = 4+ARDPlanner.fiducialScaleM/2.0*csc(ARDPlanner.hfovR/2.0); % ideal following distance
  end
  
  properties (GetAccess = private, SetAccess = private)
    ownID
    targetID
    xOwn
    vOwn
    xTarget
    vTarget
  end
  
  methods (Access = public)
    function this = ARDPlanner()
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), cfg.fastTick, cfg.slowTick);
      this = this@Msg.Time(cfg.timeSourceID, cfg.timeWarp);
      this = this@Msg.Log();
      this.ownID = cfg.ownID;
      this.targetID = cfg.targetID;
      this.xOwn = [];
      this.vOwn = [];
      this.xTarget = [];
      this.vTarget = [];
    end
    
    function sub = topics(this)
      sub{1, 1} = Msg.Proto.topic('nav.FusedState', this.ownID);
      sub{2, 1} = Msg.Proto.topic('nav.FusedState', this.targetID);
      sub{3, 1} = Msg.Proto.topic('nav.DockingState', '');
    end
    
    function process(this, inbox)
      % TODO: receive and process the full fused states of both vehicles and docking states
      if(Msg.Proto.isTopic(inbox, Msg.Proto.topic('nav.FusedState', '')))
        [~, id, pb] = Msg.Proto.unpack(inbox);
        switch(id)
          case this.ownID
            rLat = earth.WGS84.radiusOfCurvature(pb.getLatR())+pb.getAltM();
            this.xOwn = rLat*pb.getLatR();
            this.vOwn = pb.getForwardDeltaM()/pb.getTimeDeltaS();
          case this.targetID
            rLat = earth.WGS84.radiusOfCurvature(pb.getLatR())+pb.getAltM();
            this.xTarget = rLat*pb.getLatR();
            this.vTarget = pb.getForwardDeltaM()/pb.getTimeDeltaS();
          otherwise
            % nothing
        end
      end
    end
  end
end
