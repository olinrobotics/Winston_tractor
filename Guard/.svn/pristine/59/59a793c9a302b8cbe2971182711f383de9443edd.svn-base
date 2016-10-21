% An application that simulates the target interface of a satellite (which may or may not be controllable).
classdef ARDSatSimTarget < ARDSim
  properties (GetAccess = public, Constant = true)
    fgType = 'Target';
    dynamicModelName = 'ARDSimpleModel';
    vehicleModelName = 'PirsBall';
    xReal0 = [earth.WGS84.majorRadius+100000; 0; 54; 0; 0; 0; sqrt(2)/2; 0; -sqrt(2)/2; 0];
  end
  
  properties (GetAccess = private, SetAccess = private)
    cfg
  end
  
  methods (Access = public)
    function this = ARDSatSimTarget()
      cfg = JSONRead('guard.json');
      dynamicModel = ARDDynamics(ARDSatSimTarget.dynamicModelName);
      this = this@ARDSim(cfg.targetID, ARDSatSimTarget.fgType, ARDSatSimTarget.vehicleModelName, dynamicModel,...
        ARDSatSimTarget.xReal0);
      this.cfg = cfg;
    end
    
    function process(this, inbox)
      process@ARDSim(this, inbox);
      if(isempty(inbox)&&this.isReady())
        % simulate navigation sensors
        pbRPY = this.getRPY();
        pbLatLon = this.getLatLon();
        pbAlt = this.getAlt();
        pbBodyRPYDelta = this.getBodyRPYDelta();
        pbBodyFRDDelta = this.getBodyFRDDelta();
        pbBodyFRDRateDelta = this.getBodyFRDRateDelta();
        
        this.send(Msg.Proto.pack('nav.RPY', this.cfg.targetID, pbRPY));
        this.send(Msg.Proto.pack('nav.LatLon', this.cfg.targetID, pbLatLon));
        this.send(Msg.Proto.pack('nav.Alt', this.cfg.targetID, pbAlt));
        this.send(Msg.Proto.pack('nav.BodyRPYDelta', this.cfg.targetID, pbBodyRPYDelta));
        this.send(Msg.Proto.pack('nav.BodyFRDDelta', this.cfg.targetID, pbBodyFRDDelta));
        this.send(Msg.Proto.pack('nav.BodyFRDRateDelta', this.cfg.targetID, pbBodyFRDRateDelta));
        
        this.log('LatD=%+013.9f;LonD=%+014.9f;AltM=%09.2f', pbLatLon.getLatR()*math.RADTODEG,...
          pbLatLon.getLonR()*math.RADTODEG, pbAlt.getAltM());
      end
    end
  end
end
