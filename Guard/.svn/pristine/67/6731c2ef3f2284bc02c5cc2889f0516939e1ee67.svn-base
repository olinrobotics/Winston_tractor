% An application that displays all messages published to a connected switch.
classdef ARDVideoRecorder < Msg.App 
  methods (Access = public)
    function this = ARDVideoRecorder()
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), cfg.imgPeriod/2.0);
      this.vr = VideoWriter(cfg.videoName);
      this.vr.FrameRate = 1.0/cfg.imgPeriod;
      this.vr.Quality = 95.0;
      this.vr.open();
    end
    
    function delete(this)
      this.vr.close();
    end
    
    function sub = topics(this) %#ok unused input
      sub{1, 1} = Msg.Proto.topic('nav.Img', '');
    end
    
    function process(this, inbox)
      [~, ~, pb] = Msg.Proto.unpack(inbox);
      img = pbGetImg(pb);
      this.vr.writeVideo(img);
    end
  end
  
  properties (GetAccess = private, SetAccess = private)
    vr
  end
end
