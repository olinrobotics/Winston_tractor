% Enumerated behaviors.
classdef Behavior < uint8
  methods (Access = public, Static = true)
    function obj = LOITER()
      obj = Behavior(0);
    end
    function obj = APPROACH()
      obj = Behavior(1);
    end
    function obj = CAPTURE()
      obj = Behavior(2);
    end
    function obj = RELEASE()
      obj = Behavior(3);
    end
    function obj = DEPART()
      obj = Behavior(4);
    end
  end
  
  methods (Access = public)
    function this = Behavior(behavior)
      this@uint8(behavior);
    end
    
    function c = char(this)
      switch(uint8(this))
        case uint8(Behavior.APPROACH)
          c = 'APPROACH';
        case uint8(Behavior.CAPTURE)
          c = 'CAPTURE';
        case uint8(Behavior.RELEASE)
          c = 'RELEASE';
        case uint8(Behavior.DEPART)
          c = 'DEPART';
        otherwise
          c = 'LOITER';
      end
    end
  end
end
