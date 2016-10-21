% An application that simulates the ownship interface of a satellite.
classdef ARDSatSimOwn < ARDSim
  properties (GetAccess = public, Constant = true)
    fgType = 'Camera';
    dynamicModelName = 'ARDSimpleModel';
    xReal0 = [earth.WGS84.majorRadius+100000; 0; 0; 0; 0; 0; sqrt(2)/2; 0; -sqrt(2)/2; 0];
    fovR = str2double(FlightGear.Config.hfov)*math.DEGTORAD;
  end
  
  properties (GetAccess = private, SetAccess = private)
    cfg
    startTime
    isPolling
  end
  
  methods (Access = public)
    function this = ARDSatSimOwn()
      cfg = JSONRead('guard.json');
      dynamicModel = ARDDynamics(ARDSatSimOwn.dynamicModelName);
      this = this@ARDSim(cfg.ownID, ARDSatSimOwn.fgType, '', dynamicModel, ARDSatSimOwn.xReal0);
      this.cfg = cfg;
      this.startTime = -inf;
      this.isPolling = false;
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
        
        this.send(Msg.Proto.pack('nav.RPY', this.cfg.ownID, pbRPY));
        this.send(Msg.Proto.pack('nav.LatLon', this.cfg.ownID, pbLatLon));
        this.send(Msg.Proto.pack('nav.Alt', this.cfg.ownID, pbAlt));
        this.send(Msg.Proto.pack('nav.BodyRPYDelta', this.cfg.ownID, pbBodyRPYDelta));
        this.send(Msg.Proto.pack('nav.BodyFRDDelta', this.cfg.ownID, pbBodyFRDDelta));
        this.send(Msg.Proto.pack('nav.BodyFRDRateDelta', this.cfg.ownID, pbBodyFRDRateDelta));
        
        this.log('LatD=%+013.9f;LonD=%+014.9f;AltM=%09.2f', pbLatLon.getLatR()*math.RADTODEG,...
          pbLatLon.getLonR()*math.RADTODEG, pbAlt.getAltM());
        
        % simulate camera
        success = false;
        if(this.isPolling)
          [success, img] = this.pollImage();
        else
          time = this.getTime();
          if((time-this.startTime)>this.cfg.imgPeriod)
            [success, img] = this.pollImage();
            this.startTime = time;
            this.isPolling = true;
          end
        end
        if(success)
          pbImg = nav.ImgBuilder();
          pbImg.setTimeS(this.startTime);
          pbImg.setFovR(ARDSatSimOwn.fovR);
          pbSetImg(pbImg, img);
          this.send(Msg.Proto.pack('nav.Img', this.cfg.ownID, pbImg));
          this.isPolling = false;
        end
      end
    end
  end
end
