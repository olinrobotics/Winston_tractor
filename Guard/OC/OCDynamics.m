classdef OCDynamics < handle
  properties (Constant = true, GetAccess = public)
    vRateMax = 1.671778; % Hz*m/s
    kRateMax = 0.181916; % Hz/m
    uSpeedMin = int32(1355)+int32(300);
    uSpeedLow = int32(3050)+int32(300);
    uSpeedHigh = int32(4010)+int32(300);
    uSpeedMax = int32(4590)+int32(300);
    uTurnMin = int32(1800)-int32(200);
    uTurnMax = int32(4200)-int32(200);
    vLowIntercept = 8.11581*math.MPHTOMPS+300*0.00263299*math.MPHTOMPS;
    vLowSlope = -0.00263299*math.MPHTOMPS;
    vHighIntercept = 11.1818*math.MPHTOMPS+300*0.00280668*math.MPHTOMPS;
    vHighSlope = -0.00280668*math.MPHTOMPS;
    kIntercept = 0.273690/math.FTTOM-200*0.0000912363/math.FTTOM;
    kSlope = -0.0000912363/math.FTTOM;
    rpTau = 0.3; % roll and pitch time constant
    rpScale = 0.01; % roll and pitch scaling relative to acceleration
  end

  properties (GetAccess = private, SetAccess = private)
    ready;
    dt;
    vDeltaMax;
    kDeltaMax;
    rLatM;
    rLonM;
  end
  
  methods (Access = public)
    function this = OCDynamics(dt)
      % Constructor.
      this.ready = false;
      this.dt = dt;
      this.vDeltaMax = this.vRateMax*dt;
      this.kDeltaMax = this.kRateMax*dt;
    end
    
    function n = xRealSize(this) %#ok unused arguments
      n = 8;
    end

    function n = uRealSize(this) %#ok unused arguments
      n = 0;
    end

    function n = yRealSize(this) %#ok unused arguments
      n = 12;
    end
    
    function n = xIntSize(this) %#ok unused arguments
      n = 0;
    end
    
    function n = uIntSize(this) %#ok unused arguments
      n = 2;
    end
    
    function n = yIntSize(this) %#ok unused arguments
      n = 0;
    end
    
    function [xReal, yReal, xInt, yInt] = f(this, xReal0, uReal, xInt0, uInt) %#ok unused arguments
      
      % get inputs
      roll0 = xReal0(1); % roll radians
      pitch0 = xReal0(2); % pitch radians
      yaw0 = xReal0(3); % yaw radians
      lat0 = xReal0(4); % latitude radians
      lon0 = xReal0(5); % longitude radians
      alt0 = xReal0(6); % altitude meters
      w0 = xReal0(7); % yaw rate RPS
      v0 = xReal0(8); % speed MPS
      uTurn = uInt(1); % turn control setting
      uSpeed = uInt(2); % speed control setting
      
      % initialize
      if(~this.ready)
        this.rLatM = earth.WGS84.radiusOfCurvature(lat0);
        this.rLonM = cos(earth.WGS84.geodeticToGeocentric(lat0))*earth.WGS84.geodeticRadius(lat0);
        this.ready = true;
      end

      % speed lookup
      vInf = OCDynamics.vss(uSpeed);
      vDiff = vInf-v0;
      if(abs(vDiff)>this.vDeltaMax)
        v1 = v0+sign(vDiff)*this.vDeltaMax;
      else
        v1 = vInf;
      end
      vAvg = (v0+v1)/2.0;
      
      % curvature lookup
      kInf = OCDynamics.kss(uTurn);
      if(abs(v0)>eps)
        k0 = w0/v0;
      else
        k0 = kInf;
      end
      kDiff = kInf-k0;
      if(abs(kDiff)>this.kDeltaMax)
        k1 = k0+sign(kDiff)*this.kDeltaMax;
      else
        k1 = kInf;
      end
      kAvg = (k0+k1)/2.0;
      
      % planar dynamics
      w1 = k1*v1;
      wAvg = (w0+w1)/2.0;
      pathDelta = vAvg*this.dt; % same as v0*dt+0.5*a*dt^2
      [forwardDelta, rightDelta, yawDelta] = evalCircle(vAvg, wAvg, pathDelta);
      yaw1 = yaw0+yawDelta;
      yaw1 = math.Rotation.wrapToPI(yaw1);
      cy = cos(yaw0);
      sy = sin(yaw0);
      northDelta = cy*forwardDelta-sy*rightDelta;
      eastDelta = sy*forwardDelta+cy*rightDelta;
      lat1 = lat0+northDelta/this.rLatM;
      lon1 = lon0+eastDelta/this.rLonM;
      forwardRateDelta = v1-v0;
      alt1 = alt0;
      downDelta = 0.0;
      rightRateDelta = 0.0;
      downRateDelta = 0.0;
      
      % roll and pitch dynamics
      alpha = exp(-this.dt/this.rpTau);
      beta = 1.0-alpha;
      roll1 = alpha*roll0-beta*vAvg*vAvg*kAvg*this.rpScale;
      pitch1 = alpha*pitch0+beta*forwardRateDelta/this.dt*this.rpScale;
      rollDelta = roll1-roll0;
      pitchDelta = pitch1-pitch0;
      
      % set outputs
      xReal = [roll1; pitch1; yaw1; lat1; lon1; alt1; w1; v1];
      yReal = [xReal(1:6); rollDelta; pitchDelta; yawDelta; forwardDelta; rightDelta; downDelta;...
        forwardRateDelta; rightRateDelta; downRateDelta];
      xInt = zeros(this.xIntSize(), 1, 'int32');
      yInt = zeros(this.yIntSize(), 1, 'int32');
    end
  end
  
  methods (Access = public, Static = true)
    function v = vss(u)
      % Steady state speed lookup.
      if(u<OCDynamics.uSpeedMin)
        v = OCDynamics.vLowIntercept+OCDynamics.vLowSlope*double(OCDynamics.uSpeedMin);
      elseif(u<=OCDynamics.uSpeedLow)
        v = OCDynamics.vLowIntercept+OCDynamics.vLowSlope*double(u);
      elseif(u<OCDynamics.uSpeedHigh)
        v = 0.0;
      elseif(u<=OCDynamics.uSpeedMax)
        v = OCDynamics.vHighIntercept+OCDynamics.vHighSlope*double(u);
      else
        v = OCDynamics.vHighIntercept+OCDynamics.vHighSlope*double(OCDynamics.uSpeedMax);
      end
    end
    
    function u = vssInv(v)
      % Steady state speed inverse lookup.
      if(isnan(v))
        u = (OCDynamics.uSpeedLow+OCDynamics.uSpeedHigh)/int32(2);
      elseif(v<OCDynamics.vss(OCDynamics.uSpeedMax))
        u = OCDynamics.uSpeedMax;
      elseif(v<=OCDynamics.vss(OCDynamics.uSpeedHigh))
        u = int32((v-OCDynamics.vHighIntercept)/OCDynamics.vHighSlope);
      elseif(v<OCDynamics.vss(OCDynamics.uSpeedLow))
        u = (OCDynamics.uSpeedLow+OCDynamics.uSpeedHigh)/int32(2);
      elseif(v<=OCDynamics.vss(OCDynamics.uSpeedMin))
        u = int32((v-OCDynamics.vLowIntercept)/OCDynamics.vLowSlope);
      else
        u = OCDynamics.uSpeedMin;
      end
    end
    
    function k = kss(u)
      % Steady state curvature lookup.
      if(u<OCDynamics.uTurnMin)
        k = OCDynamics.kIntercept+OCDynamics.kSlope*double(OCDynamics.uTurnMin);
      elseif(u<=OCDynamics.uTurnMax)
        k = OCDynamics.kIntercept+OCDynamics.kSlope*double(u);
      else
        k = OCDynamics.kIntercept+OCDynamics.kSlope*double(OCDynamics.uTurnMax);
      end
    end
    
    function u = kssInv(k)
      % Steady state curvature inverse lookup.
      if(isnan(k))
        u = (OCDynamics.uTurnMax+OCDynamics.uTurnMin)/int32(2);
      elseif(k<OCDynamics.kss(OCDynamics.uTurnMax))
        u = OCDynamics.uTurnMax;
      elseif(k<=OCDynamics.kss(OCDynamics.uTurnMin))
        u = int32((k-OCDynamics.kIntercept)/OCDynamics.kSlope);
      else
        u = OCDynamics.uTurnMin;
      end
    end
    
    function Test()
      close('all');
      
      dt = 0.1;
      
      figure(1);
      hold('on');
      title('Steady State Speed Validation');
      xlabel('uSpeed [CLICKS]');
      ylabel('vInf [MPH]');
      uSpeed = int32(1000:5:5000);
      for n = 1:numel(uSpeed)
        vInf = OCDynamics.vss(uSpeed(n));
        plot(uSpeed(n), vInf*math.MPSTOMPH, 'rx');
        plot(OCDynamics.vssInv(vInf), vInf*math.MPSTOMPH, 'b+');
      end
      uSpeedData = [1355, 1700, 2010, 2200, 2450, 2785, 3050, 3500, 4010, 4100, 4168, 4233, 4400, 4590];
      vInfData = [4.520, 3.610, 2.910, 2.230, 1.680, 1.040, 0.085, 0.000, -0.073, -0.277, -0.448, -0.748, -1.120, -1.740];
      plot(uSpeedData, vInfData, 'go');
      drawnow;
      
      figure(2);
      hold('on');
      title('Steady State Turn Validation');
      xlabel('uTurn [CLICKS]');
      ylabel('kInf [1/FT]');
      uTurn = int32(1000:5:5000);
      for n = 1:numel(uTurn)
        kInf = OCDynamics.kss(uTurn(n));
        plot(uTurn(n), kInf/math.MTOFT, 'rx');
        plot(OCDynamics.kssInv(kInf), kInf/math.MTOFT, 'b+');
      end
      uTurnData = [1800, 2200, 2600, 2800, 2850, 3000, 3100, 3200, 3400, 3800, 4200];
      kInfData = 1./[9.1250, 14.2917, 32.6458, 73.0833, 106.7500, inf, -112.3542, -57.4271, -30.7292, -13.7292, -8.60421];
      plot(uTurnData, kInfData, 'go');
      drawnow;
      
      figure(3);
      hold('on');
      title(sprintf('Planar Model Response to u = [%d; %d]', OCDynamics.uTurnMin, OCDynamics.uSpeedMin));
      xlabel('east [FT]');
      ylabel('north [FT]');
      dynamicModel = OCDynamics(dt);
      xReal = zeros(dynamicModel.xRealSize(), 1);
      uReal = zeros(dynamicModel.uRealSize(), 1);
      xInt = zeros(dynamicModel.xIntSize(), 1);
      uInt = [OCDynamics.uTurnMin; OCDynamics.uSpeedMin];
      for n = 1:100
        [xReal, yReal, xInt, yInt] = dynamicModel.f(xReal, uReal, xInt, uInt); %#ok unused outputs
        east = yReal(5)*dynamicModel.rLonM*math.MTOFT;
        north = yReal(4)*dynamicModel.rLatM*math.MTOFT;
        yaw = yReal(3);
        plot([east, east+0.3*sin(yaw)], [north, north+0.3*cos(yaw)], 'r-');
        plot(east, north, 'r.');
      end
      plot(1.0/OCDynamics.kss(OCDynamics.uTurnMin)*math.MTOFT, 0, 'bx');
      axis('equal');
      drawnow;
      
      figure(4);
      hold('on');
      title(sprintf('Orientation Model Response to u = [%d; %d]', OCDynamics.uTurnMin, OCDynamics.uSpeedMin));
      xlabel('time [S]');
      ylabel('RPY [D]');
      dynamicModel = OCDynamics(dt);
      xReal = zeros(dynamicModel.xRealSize(), 1);
      uReal = zeros(dynamicModel.uRealSize(), 1);
      xInt = zeros(dynamicModel.xIntSize(), 1);
      uInt = [OCDynamics.uTurnMin; OCDynamics.uSpeedMin];
      for n = 1:100
        time = n*dynamicModel.dt;
        [xReal, yReal, xInt, yInt] = dynamicModel.f(xReal, uReal, xInt, uInt); %#ok unused outputs
        plot(time, yReal(1)*math.RADTODEG, 'r.');
        plot(time, yReal(2)*math.RADTODEG, 'g.');
        plot(time, yReal(3)*math.RADTODEG, 'b.');
      end
      legend({'roll', 'pitch', 'yaw'});
      drawnow;
    end
  end
end

function [x, y, p] = evalCircle(v0, pd0, s)
if(abs(pd0)<=eps)
  r0 = inf;
else
  r0 = v0/pd0;
end
absr0 = abs(r0);
if(absr0<=eps)
  p = 0.0;
  x = 0.0;
  y = 0.0;
elseif(absr0>=(1.0/eps))
  p = 0.0;
  x = s;
  y = 0.0;
else
  p = s/r0;
  x = r0*sin(p);
  y = r0*(1.0-cos(p));
end
end
