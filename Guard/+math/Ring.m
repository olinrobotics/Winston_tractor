classdef Ring < handle
  properties (GetAccess = public, SetAccess = private)
    K;
    k;
    x;
  end
  
  methods (Access = public)
    function this = Ring(K)
      this.K = uint32(K+1);
      this.k = uint32(0);
      this.x = cell(this.K, 1);
    end
    
    function y = swap(this, x)
      kp = this.k+1;
      this.x{kp} = x;
      this.k = mod(kp, this.K);
      y = this.x{this.k+1};
    end
  end
end
