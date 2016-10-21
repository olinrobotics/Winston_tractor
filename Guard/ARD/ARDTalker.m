% An application that logs heartbeats.
classdef ARDTalker < Msg.App & Msg.Log
  methods (Access = public)
    function this = ARDTalker()
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), inf, cfg.slowTick);
      this = this@Msg.Log();
    end

    function sub = topics(this) %#ok unused input
      sub = cell(0, 1); % do not subscribe
    end
    
    function process(this, inbox) %#ok unused input
      this.log('Testing ARDTalker.m');
    end
  end
end
