% Optionally inherited time synchronization system.
classdef Time < handle
  methods (Access = public)
    function usec = tick(this) %#ok unused input
      % Get system time as an integer.
      %
      % @param[out] usec system time as an integer
      usec = tic;
    end
    
    function dt = tock(this, usec)
      % Compute elapsed time.
      %
      % @param[in]  usec system time as an integer
      % @param[out] dt   elapsed time in seconds
      dt = this.msgTimeWarp*toc(usec);
    end
    
    function flag = isTimeSet(this)
      % Determine whether the time has been set.
      %
      % @param[out] flag indicates whether time has been set
      flag = this.msgTimeSet;
    end
    
    function setTime(this, time)
      % Set the current time.
      %
      % @param[in] time value to accept as the current time
      this.msgTimeSys = tic;
      this.msgTimeRef = time;
      this.msgTimeSet = true;
    end
    
    function time = getTime(this)
      % Get the current time.
      %
      % @param[out] time current time including warp factor
      if(this.msgTimeSet)
        sysTime = toc(this.msgTimeSys);
        time = this.msgTimeRef+this.msgTimeWarp*sysTime;
      else
        time = this.msgTimeRef;
      end
    end
    
    function sendTime(this)
      % Publish the current time.
      time = this.getTime();
      msgTime = msg.TimeBuilder();
      msgTime.setTimeS(time);
      this.msgApp.send(Msg.Proto.pack('msg.Time', this.msgApp.msgAppID, msgTime));
    end
    
    function sub = msgTopicsTime(this)
      % Inserts a time topic.
      %
      % @param[in] sub cell array of message headers defining subscription topics
      sub = cell(0, 1);
      if(~strcmp(this.msgApp.msgAppID, this.msgTimeSourceID))
        sub{1, 1} = this.msgTimeTopic;
      end
    end
    
    function msgProcessTime(this, inbox)
      % Inserts a time handling process.
      %
      % @param[in] inbox input message (may be empty)
      if(~isempty(this.msgTimeTopic))
        if(Msg.Proto.isTopic(inbox, this.msgTimeTopic))
          [~, ~, msgTime] = Msg.Proto.unpack(inbox);
          time = msgTime.getTimeS();
          if(time>this.getTime())
            this.setTime(time);
          end
        end
      end
    end
  end
  
  methods (Access = protected)
    function this = Time(msgTimeSourceID, msgTimeWarp)
      % Constructor.
      %
      % @param[in] msgTimeSourceID application identifier of time source
      % @param[in] msgTimeWarp     time scaling parameter
      this.msgApp = this;
      if(isempty(this.msgApp.msgAppID))
        error('Time: App must be initialized before Time');
      end
      this.msgTimeSourceID = msgTimeSourceID;
      this.msgTimeWarp = msgTimeWarp;
      this.msgTimeSys = uint64(0);
      this.msgTimeRef = 0.0;
      this.msgTimeSet = false;
      if(strcmp(this.msgApp.msgAppID, this.msgTimeSourceID))
        this.msgTimeTopic = '';
      else
        this.msgTimeTopic = Msg.Proto.topic('msg.Time', this.msgTimeSourceID);
      end
      this.msgApp.msgTime = this;
    end
  end
  
  properties (GetAccess = private, SetAccess = private)
    msgApp;
    msgTimeSourceID;
    msgTimeWarp;
    msgTimeSet;
    msgTimeSys;
    msgTimeRef;
    msgTimeTopic;
  end
end
