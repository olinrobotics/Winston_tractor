% Optionally inherited text logging system.
classdef Log < handle
  methods (Access = public)    
    function log(this, format, varargin)
      % Send a log message at the next opportunity.
      %
      % @param[in] format   @see sprintf()
      % @param[in] varargin @see sprintf()
      assert(isa(format, 'char'));
      text = sprintf(format, varargin{:});
      pbMsgLog = msg.LogBuilder();
      pbMsgLog.setText(text);
      pb = Msg.Proto.pack('msg.Log', this.msgApp.msgAppID, pbMsgLog);
      this.msgApp.send(pb);
    end
  end
    
  methods (Access = protected)
    function this = Log()
      % Constructor.
      %
      % @note initialize using this@MsgLog
      this.msgApp = this;
      if(isempty(this.msgApp.msgAppID))
        error('Log: App must be initialized before Log');
      end
    end
  end
  
  properties (GetAccess = private, SetAccess = private)
    msgApp;
  end
end
