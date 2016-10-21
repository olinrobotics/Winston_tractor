classdef ARDDriverTarget < ARDDriver
  methods (Access = public)
    function this = ARDDriverTarget()
      cfg = JSONRead('guard.json');
      this = this@ARDDriver(cfg.targetID);
    end
  end
end
