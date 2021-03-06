% Dynamic and graphic model for vehicle simulations.
classdef ARDSim < Msg.App & Msg.Time & Msg.Log
  properties (GetAccess = public, Constant = true)
    port = FlightGear.Base.nextPort(FlightGear.Config.multiPortRange);
  end
  
  properties (GetAccess = private, SetAccess = private)
    cfg
    vehicleID
    dynamicModel
    xReal
    uReal
    xInt
    uInt
    yReal
    yInt
    time
    graphicModel
    ready
  end
  
  methods (Access = public)
    function this = ARDSim(vehicleID, fgType, vehicleName, dynamicModel, xReal0, uReal0, xInt0, uInt0)
      if(nargin<5)
        xReal0 = zeros(dynamicModel.xRealSize(), 1);
      end
      if(nargin<6)
        uReal0 = zeros(dynamicModel.uRealSize(), 1);
      end
      if(nargin<7)
        xInt0 = zeros(dynamicModel.xIntSize(), 1, 'int32');
      end
      if(nargin<8)
        uInt0 = zeros(dynamicModel.uIntSize(), 1, 'int32');
      end
      cfg = JSONRead('guard.json');
      this = this@Msg.App(vehicleID, cfg.ctrlTick, cfg.ctrlTick);
      this = this@Msg.Time(cfg.timeSourceID, cfg.timeWarp);
      this = this@Msg.Log();
      this.cfg = cfg;
      this.vehicleID = vehicleID;
      this.dynamicModel = dynamicModel;
      this.xReal = xReal0;
      this.uReal = uReal0;
      this.xInt = xInt0;
      this.uInt = uInt0;
      [~, this.yReal, ~, this.yInt] = this.dynamicModel.f(this.xReal, this.uReal, this.xInt, this.uInt);
      this.time = 0.0;
      this.ready = false;
      if(abs(cfg.ctrlTick-1.0/str2double(FlightGear.Config.hz))>eps)
        warning('ARDSim: FlightGear simulation period differs from ctrlTick');
      end
      switch(fgType)
        case 'Camera'
          pbRPY = this.getRPY();
          pbLatLon = this.getLatLon();
          pbAlt = this.getAlt();
          this.graphicModel = FlightGear.Camera({this.port}, pbLatLon.getLatR()*math.RADTODEG,...
            pbLatLon.getLonR()*math.RADTODEG, pbAlt.getAltM()*math.MTOFT, pbRPY.getRollR()*math.RADTODEG,...
            pbRPY.getPitchR()*math.RADTODEG, pbRPY.getYawR()*math.RADTODEG);
        case 'Target'
          pbRPY = this.getRPY();
          pbLatLon = this.getLatLon();
          pbAlt = this.getAlt();
          this.graphicModel = FlightGear.Target(this.port, vehicleName, cfg.targetID,...
            pbLatLon.getLatR()*math.RADTODEG, pbLatLon.getLonR()*math.RADTODEG, pbAlt.getAltM()*math.MTOFT,...
            pbRPY.getRollR()*math.RADTODEG, pbRPY.getPitchR()*math.RADTODEG, pbRPY.getYawR()*math.RADTODEG);
        otherwise
          this.graphicModel = [];
      end
    end
    
    function delete(this)
      this.dynamicModel.delete();
      if(~isempty(this.graphicModel))
        this.graphicModel.delete();
        this.graphicModel = [];
      end
    end
    
    function sub = topics(this)
      sub{1, 1} = Msg.Proto.topic('nav.Ctrl', this.vehicleID);
    end
    
    function process(this, inbox)
      if(~this.ready)
        if(this.isTimeSet()&&(~this.isBusy()))
          this.time = this.getTime();
          this.ready = true;
        end
        return;
      end
      
      if(isempty(inbox))
        this.refreshDynamicModel();
        this.refreshGraphicModel();
      else
        [type, id, pb] = Msg.Proto.unpack(inbox);
        if(strcmp(id, this.vehicleID));
          switch(type)
            case 'nav.Ctrl'
              N = pb.getURealCount();
              this.uReal = zeros(N, 1);
              for n = 1:N
                this.uReal(n) = pb.getUReal(n-1);
              end
              N = pb.getUIntCount();
              this.uInt = zeros(N, 1);
              for n = 1:N
                this.uInt(n) = pb.getUInt(n-1);
              end
            otherwise
              % nothing
          end
        end
      end
    end
    
    function [success, img] = pollImage(this, varargin)
      if(isempty(this.graphicModel))
        success = false;
        img = [];
      else
        [success, img] = this.graphicModel.pollImage(varargin{:});
      end
    end
    
    function flag = isBusy(this)
      if(isempty(this.graphicModel))
        flag = false;
      else
        flag = this.graphicModel.isBusy();
      end
    end
    
    function flag = isReady(this)
      flag = this.ready;
    end
    
    function pbRPY = getRPY(this)
      pbRPY = nav.RPYBuilder();
      pbRPY.setTimeS(this.time);
      pbRPY.setRollR(this.yReal(1));
      pbRPY.setPitchR(this.yReal(2));
      pbRPY.setYawR(this.yReal(3));
    end
    
    function pbLatLon = getLatLon(this)
      pbLatLon = nav.LatLonBuilder();
      pbLatLon.setTimeS(this.time);
      pbLatLon.setLatR(this.yReal(4));
      pbLatLon.setLonR(this.yReal(5));
    end
    
    function pbAlt = getAlt(this)
      pbAlt = nav.AltBuilder();
      pbAlt.setTimeS(this.time);
      pbAlt.setAltM(this.yReal(6));
    end
    
    function pbBodyRPYDelta = getBodyRPYDelta(this)
      pbBodyRPYDelta = nav.BodyRPYDeltaBuilder();
      pbBodyRPYDelta.setTimeS(this.time);
      pbBodyRPYDelta.setTimeDeltaS(this.cfg.ctrlTick);
      pbBodyRPYDelta.setRollDeltaR(this.yReal(7));
      pbBodyRPYDelta.setPitchDeltaR(this.yReal(8));
      pbBodyRPYDelta.setYawDeltaR(this.yReal(9));
    end
    
    function pbBodyFRDDelta = getBodyFRDDelta(this)
      pbBodyFRDDelta = nav.BodyFRDDeltaBuilder();
      pbBodyFRDDelta.setTimeS(this.time);
      pbBodyFRDDelta.setTimeDeltaS(this.cfg.ctrlTick);
      pbBodyFRDDelta.setForwardDeltaM(this.yReal(10));
      pbBodyFRDDelta.setRightDeltaM(this.yReal(11));
      pbBodyFRDDelta.setDownDeltaM(this.yReal(12));
    end
    
    function pbBodyFRDRateDelta = getBodyFRDRateDelta(this)
      pbBodyFRDRateDelta = nav.BodyFRDRateDeltaBuilder();
      pbBodyFRDRateDelta.setTimeS(this.time);
      pbBodyFRDRateDelta.setTimeDeltaS(this.cfg.ctrlTick);
      pbBodyFRDRateDelta.setForwardRateDeltaMPS(this.yReal(13));
      pbBodyFRDRateDelta.setRightRateDeltaMPS(this.yReal(14));
      pbBodyFRDRateDelta.setDownRateDeltaMPS(this.yReal(15));
    end
  end
  
  methods (Access = private)
    function refreshDynamicModel(this)
      % update dynamic model
      while((this.time+this.cfg.ctrlTick)<=this.getTime())
        [this.xReal, this.yReal, this.xInt, this.yInt] = this.dynamicModel.f(this.xReal, this.uReal, this.xInt,...
          this.uInt);
        this.time = this.time+this.cfg.ctrlTick;
      end
    end
    
    function refreshGraphicModel(this)
      % update graphic model
      if(~isempty(this.graphicModel))
        pbRPY = this.getRPY();
        pbLatLon = this.getLatLon();
        pbAlt = this.getAlt();
        this.graphicModel.setLLARPY(pbLatLon.getLatR()*math.RADTODEG, pbLatLon.getLonR()*math.RADTODEG,...
          pbAlt.getAltM()*math.MTOFT, pbRPY.getRollR()*math.RADTODEG, pbRPY.getPitchR()*math.RADTODEG,...
          pbRPY.getYawR()*math.RADTODEG);
      end
    end
  end
end
