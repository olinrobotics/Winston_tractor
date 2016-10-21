classdef ARDDriverOwn < ARDDriver
  methods (Access = public)
    function this = ARDDriverOwn()
      cfg = JSONRead('guard.json');
      this = this@ARDDriver(cfg.ownID);
    end
  end
end
