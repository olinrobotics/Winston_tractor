classdef ARDCmdTest < Msg.App & Msg.Cmd
  methods (Access = public)
    function this = ARDCmdTest()
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), cfg.fastTick, cfg.slowTick, cfg.maxLength);
      this = this@Msg.Cmd(cfg.ackPeriod, cfg.timeWarp);
    end

    function done = init(this) %#ok unused input
      fprintf('INIT\n');
      done = true;
    end
    
    function idle(this, inbox) %#ok unused input
      fprintf('IDLE\n');
    end
    
    function done = run(this, inbox) %#ok unused input
      fprintf('RUN\n');
      done = false;
    end
    
    function term(this) %#ok unused input
      fprintf('TERM\n');
    end
  end
end
