% An application that simulates the ownship interface of a tractor.
classdef OCTractorSimOwn < ARDSim
  properties (GetAccess = public, Constant = true)
    % graphical simulator requires dynamics to be expressed in terms of the camera frame
    fgType = '';%'Camera';
    initialOffsetLatR = -0.000001;
    initialOffsetLonR = 0.0;
    initialOffsetAltM = -getfield(JSONRead('guard.json'), 'cameraDownM');
    latR0 = OCTractorSimTarget.latR0+OCTractorSimOwn.initialOffsetLatR;
    lonR0 = OCTractorSimTarget.lonR0+OCTractorSimOwn.initialOffsetLonR;
    altM0 = OCTractorSimTarget.altM0+OCTractorSimOwn.initialOffsetAltM;
    xReal0 = [zeros(3, 1); OCTractorSimOwn.latR0; OCTractorSimOwn.lonR0; OCTractorSimOwn.altM0; zeros(3, 1)];
    uInt0 = [OCDynamics.kssInv(0); OCDynamics.vssInv(0)];
    rLatM = earth.WGS84.radiusOfCurvature(OCTractorSimOwn.latR0);
    rLonM = cos(earth.WGS84.geodeticToGeocentric(OCTractorSimOwn.latR0))*earth.WGS84.geodeticRadius(OCTractorSimOwn.latR0);
    fovR = str2double(FlightGear.Config.hfov)*math.DEGTORAD;
  end
  
  properties (GetAccess = private, SetAccess = private)
    cfg
    startTime
    isPolling
  end
  
  methods (Access = public)
    function this = OCTractorSimOwn()
      cfg = JSONRead('guard.json');
      dynamicModel = OCDynamics(cfg.ctrlTick);
      this = this@ARDSim(cfg.ownID, OCTractorSimOwn.fgType, '', dynamicModel, OCTractorSimOwn.xReal0, zeros(0, 1),...
        zeros(0, 1, 'int32'), OCTractorSimOwn.uInt0);
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
        
        % transform camera frame dynamics to body frame
        yaw = pbRPY.getYawR();
        lat = pbLatLon.getLatR();
        lon = pbLatLon.getLonR();
        alt = pbAlt.getAltM();
        lat = lat-cos(yaw)*this.cfg.cameraForwardM/this.rLatM;
        lon = lon-sin(yaw)*this.cfg.cameraForwardM/this.rLonM;
        alt = alt+this.cfg.cameraDownM;
        pbLatLon.setLatR(lat);
        pbLatLon.setLonR(lon);
        pbAlt.setAltM(alt);
        
        this.send(Msg.Proto.pack('nav.RPY', this.cfg.ownID, pbRPY));
        this.send(Msg.Proto.pack('nav.LatLon', this.cfg.ownID, pbLatLon));
        this.send(Msg.Proto.pack('nav.Alt', this.cfg.ownID, pbAlt));
        this.send(Msg.Proto.pack('nav.BodyRPYDelta', this.cfg.ownID, pbBodyRPYDelta));
        this.send(Msg.Proto.pack('nav.BodyFRDDelta', this.cfg.ownID, pbBodyFRDDelta));
        
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
          pbImg.setFovR(OCTractorSimOwn.fovR);
          pbSetImg(pbImg, img);
          this.send(Msg.Proto.pack('nav.Img', this.cfg.ownID, pbImg));
          this.isPolling = false;
        end
      end
    end
  end
end
