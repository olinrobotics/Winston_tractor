classdef OCPID < handle
  properties (GetAccess = public, SetAccess = public)
    dt
    kp
    ki
    kd
    y1
    x1
    x2
  end
  
  methods (Access = public)
    function this = OCPID(dt, kp, ki, kd)
      this.dt = dt;
      this.kp = kp;
      this.ki = ki;
      this.kd = kd;
      this.y1 = 0.0;
      this.x1 = 0.0;
      this.x2 = 0.0;
    end
    
    function y = f(this, x)
      a = this.kp+0.5*this.ki*this.dt+this.kd/this.dt;
      b = -this.kp+0.5*this.ki*this.dt-2.0*this.kd/this.dt;
      c = this.kd/this.dt;
      y = this.y1+a*x+b*this.x1+c*this.x2;
      this.y1 = y;
      this.x2 = this.x1;
      this.x1 = x;
    end
  end
end
