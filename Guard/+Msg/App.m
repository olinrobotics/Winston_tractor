% Abstract base class from which all message applications derive.
classdef App < handle
  properties (GetAccess = public, SetAccess = public)
    msgAppID;
    msgCommsTick;
    msgAppTick;
    msgMaxLength;
    msgOutbox;
    msgTime;
    msgCmd;
  end
  
  methods (Access = public)
     function sub = topics(this) %#ok unused input
      % Default subscription topics (derived class should override).
      %
      % @param[in] sub cell array of message headers defining subscription topics
      sub = cell(0, 1);
    end
    
    function process(this, inbox) %#ok unused input
      % Default process for handling all message types (derived class should override).
      %
      % @param[in] inbox input message (may be empty)
    end
    
    function send(this, message)
      % Send a message at the next opportunity.
      %
      % @param[in] outbox message to send
      assert(isa(message, 'char'));
      assert(size(message, 1)<=1);
      this.msgOutbox = cat(1, this.msgOutbox, message);
    end
    
    function msgTimeHandler(this, msgTime)
      this.msgTime = msgTime;
    end
    
    function msgCmdHandler(this, msgCmd)
      this.msgCmd = msgCmd;
    end
    
    function sub = msgTopics(this)
      % Get subscription topics.
      sub = cell(0, 1);
      if(~isempty(this.msgTime))
        sub = cat(1, sub, this.msgTime.msgTopicsTime());
      end
      if(~isempty(this.msgCmd))
        sub = cat(1, sub, this.msgCmd.msgTopicsCmd());
      end
      sub = cat(1, sub, this.topics());
    end
    
    function msgProcess(this, inbox)
      % Main process.
      if(~isempty(this.msgTime))
        this.msgTime.msgProcessTime(inbox);
      end
      if(~isempty(this.msgCmd))
        this.msgCmd.msgProcessCmd(inbox);
      end
      this.process(inbox);
    end
    
    function msgClear(this)
      % Clear message outbox.
      this.msgOutbox = cell(0, 1);
    end
  end
  
  methods (Access = protected)
    function this = App(msgAppID, msgCommsTick, msgAppTick, msgMaxLength)
      % Base class constructor that must be called from the derived class with at least one argument.
      %
      % @param[in] msgAppID     unique application identifier
      % @param[in] msgCommsTick desired maximum time interval between checking for incoming messages (default=1.0)
      % @param[in] msgAppTick   desired time interval between iterations with guaranteed empty inbox (default=inf)
      % @param[in] msgMaxLength maximum incoming message length (remainder will be truncated) (default=67108864)
      if(nargin==0)
        error('App: Constructor must be called with at least one argument.');
      end
      assert(isa(msgAppID, 'char'));
      this.msgAppID = msgAppID;
      if(nargin>=2)
        assert(isa(msgCommsTick, 'double'));
        this.msgCommsTick = msgCommsTick;
      else
        this.msgCommsTick = 1.0;
      end
      if(nargin>=3)
        assert(isa(msgAppTick, 'double'));
        this.msgAppTick = msgAppTick;
      else
        this.msgAppTick = inf;
      end
      if(nargin>=4)
        this.msgMaxLength = uint32(msgMaxLength);
      else
        this.msgMaxLength = uint32(67108864);
      end
      this.msgOutbox = cell(0, 1);
      this.msgTime = [];
      this.msgCmd = [];
    end
  end
end
