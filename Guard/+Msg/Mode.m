% Enumerated run-level command set.
classdef Mode < uint8
  methods (Access = public, Static = true)
    function obj = OFF()
      obj = Msg.Mode(0);
    end
    function obj = IDLE()
      obj = Msg.Mode(1);
    end    
    function obj = RUN()
      obj = Msg.Mode(2);
    end
  end
  
  methods (Access = public)
    function this = Mode(mode)
      this@uint8(mode);
    end
    
    function c = char(this)
      switch(uint8(this))
        case uint8(Msg.Mode.IDLE)
          c = 'IDLE';
        case uint8(Msg.Mode.RUN)
          c = 'RUN';
        otherwise
          c = 'OFF';
      end
    end
  end
end
