% syms x0 x1 x2 x3 x4 x5 xd0 xd1 xd2 u0 u1 u2 dt
% x = [x0; x1; x2; x3; x4; x5];
% u = [u0; u1; u2];
% Z = zeros(3);
% I = eye(3);
% A = [Z, I; Z, Z];
% B = [Z; I];
% C = [I, Z; Z, I];
% D = [Z; Z];
% Ad = expm(A*dt);
% Bd = A\(Ad-eye(6))*B;
% x = Ad*x+Bd*u;
% y = C*x+D*u;
classdef ARDDynamics < handle
  properties (SetAccess = private, GetAccess = private)
    hasFastRestart
    modelName
    xReal0
    uReal
    xInt0
    uInt
  end
  
  methods (Access = public)
    function this = ARDDynamics(modelName)
           
      % load the model
      this.modelName = modelName;
      load_system(this.modelName);
      
      % use fast restart if available
      matlabVersionString = version('-release');
      matlabVersion = str2double(matlabVersionString(1:4));
      this.hasFastRestart = (matlabVersion>=2016);
      if(this.hasFastRestart)
        set_param(this.modelName, 'FastRestart', 'on');
      end
      
      % initialize input signals
      this.xReal0.time = 0.0;
      this.xReal0.signals.values = repmat(eps, 1, this.xRealSize());
      this.xReal0.signals.dimensions = this.xRealSize();
      this.uReal.time = 0.0;
      this.uReal.signals.values = repmat(eps, 1, this.uRealSize());
      this.uReal.signals.dimensions = this.uRealSize();
      this.xInt0.time = 0.0;
      this.xInt0.signals.values = zeros(1, this.xIntSize(), 'uint8');
      this.xInt0.signals.dimensions = this.xIntSize();
      this.uInt.time = 0.0;
      this.uInt.signals.values = zeros(1, this.uIntSize(), 'uint8');
      this.uInt.signals.dimensions = this.uIntSize();
      
      % initilize the model
      fSandbox(this.modelName, this.xReal0, this.uReal, this.xInt0, this.uInt);
    end
    
    function delete(this)
      if(bdIsLoaded(this.modelName))
        if(this.hasFastRestart)
          set_param(this.modelName, 'FastRestart', 'off');
        end
        close_system(this.modelName);
      end
    end
    
    function n = xRealSize(this)
      n = str2double(get_param([this.modelName, '/xRealSpec'], 'Dimensions'));
    end

    function n = uRealSize(this)
      n = str2double(get_param([this.modelName, '/uRealSpec'], 'Dimensions'));
    end

    function n = yRealSize(this)
      n = str2double(get_param([this.modelName, '/yRealSpec'], 'Dimensions'));
    end
    
    function n = xIntSize(this)
      n = str2double(get_param([this.modelName, '/xIntSpec'], 'Dimensions'));
    end
    
    function n = uIntSize(this)
      n = str2double(get_param([this.modelName, '/uIntSpec'], 'Dimensions'));
    end
    
    function n = yIntSize(this)
      n = str2double(get_param([this.modelName, '/yIntSpec'], 'Dimensions'));
    end
    
    function [xReal, yReal, xInt, yInt] = f(this, xReal0, uReal, xInt0, uInt)
      if(nargin<5)
        uInt = zeros(this.uIntSize(), 1, 'uint8');
        if(nargin<4)
          xInt0 = zeros(this.xIntSize(), 1, 'uint8');
        end
      end
      this.xReal0.signals.values(:) = xReal0(:);
      this.uReal.signals.values(:) = uReal(:);
      this.xInt0.signals.values(:) = xInt0(:);
      this.uInt.signals.values(:) = uInt(:);
      out = fSandbox(this.modelName, this.xReal0, this.uReal, this.xInt0, this.uInt);
      xReal = out.get('xReal')';
      if(nargout>1)
        yReal = out.get('yReal')';
        if(nargout>2)
          xInt = out.get('xInt')';
          if(nargout>3)
            yInt = out.get('yInt')';
          end
        end
      end
    end
  end
  
  methods (Access = public, Static = true)
    function Test(varargin)
      if(nargin==0)
        modelName = 'ARDSimpleModel';
      else
        modelName = varargin{1};
      end
      addpath(fileparts(fileparts(mfilename('fullpath'))));
      this = ARDDynamics(modelName);
      x0 = [earth.WGS84.majorRadius; 0; 0; 0; 0; 0; 1; 0; 0; 0];
      u = [1; 0; 0; 0; 0; 0];
      x = this.f(x0, u);
      x(1) = x(1)-earth.WGS84.majorRadius;
      disp(x);
    end
  end
end

function out = fSandbox(modelName, xReal0, uReal, xInt0, uInt) %#ok inputs are used in the simulink model
  out = sim(modelName, 'SrcWorkspace', 'current');
end
