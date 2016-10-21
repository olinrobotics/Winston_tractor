% An application that issues commands and receives acknowledgements.
classdef ARDAutonomy < Msg.App & Msg.Time & Msg.Log
  properties (Constant = true, GetAccess = public)
    remoteControl = 'ARDCommander'; % accepts signals from this source
  end
  
  properties (GetAccess = private, SetAccess = private)
    ackPeriod % double
    tDanger % double
    ownID % string
    targetID % string
    
    cmdRequest % Msg.Mode
    cmdMode % Msg.Mode
    missionRequest % Behavior
    missionBehavior % Behavior
    
    appAckID % string
    appAckMode % Msg.Mode
    appAckTick % uint64
    
    ownInit % bool
    targetInit % bool
    own % nav.FusedState
    target % nav.FusedState
  end
  
  methods (Access = public)
    function this = ARDAutonomy()
      % Constructor.
      
      % initialize base classes
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), cfg.fastTick, cfg.ackPeriod, cfg.maxLength);
      this = this@Msg.Time(cfg.timeSourceID, cfg.timeWarp);
      this = this@Msg.Log();
      
      % initialize states
      this.ackPeriod = cfg.ackPeriod;
      this.tDanger = cfg.tDanger;
      this.ownID = cfg.ownID;
      this.targetID = cfg.targetID;
      
      this.cmdRequest = Msg.Mode.OFF;
      this.cmdMode = Msg.Mode.OFF;
      this.missionRequest = Behavior.LOITER;
      this.missionBehavior = Behavior.LOITER;

      this.appAckID = cell(0, 1);
      this.appAckMode = repmat(Msg.Mode.OFF, 0, 1);
      this.appAckTick = zeros(0, 1, 'uint64');

      this.ownInit = false;
      this.targetInit = false;
      
      % initial output
      this.sendAll();
    end
    
    function sub = topics(this)
      sub{1, 1} = Msg.Proto.topic('msg.Cmd', this.remoteControl);
      sub{2, 1} = Msg.Proto.topic('nav.Mission', this.remoteControl);
      sub{3, 1} = Msg.Proto.topic('msg.Ack', '');
      sub{4, 1} = Msg.Proto.topic('nav.FusedState', this.ownID);
      sub{5, 1} = Msg.Proto.topic('nav.FusedState', this.targetID);
    end
    
    function process(this, inbox)
      if(~isempty(inbox))
        this.processInbox(inbox);
      else
        
        % if the command request is greater than the current command
        if(this.cmdRequest>this.cmdMode)
          
          % for each application
          for n = 1:numel(this.appAckID)
            
            % if long time has passed
            if(this.tock(this.appAckTick(n))>=this.tDanger)
              
              % treat as OFF
              this.appAckMode(n) = Msg.Mode.OFF;
            end
          end
          
          % if applications are synchronized with each other
          if(all(this.appAckMode>=this.cmdMode))
            
            % increment the command
            this.cmdMode = ARDAutonomy.modeUp(this.cmdMode);
          end
          
        % if the command request is less than the current command
        elseif(this.cmdRequest<this.cmdMode)
          
          % set the command
          this.cmdMode = this.cmdRequest;
        
        end
        
        % TODO: insert correct docking logic that transitions behavior based on vehicle states
        this.missionBehavior = this.missionRequest;
        
        % send output
        this.sendAll();
      end
    end
  end
  
  methods (Access = private, Static = true)
    function mode = modeUp(mode)
      switch(uint8(mode))
        case uint8(Msg.Mode.OFF)
          mode = Msg.Mode.IDLE;
        case uint8(Msg.Mode.IDLE)
          mode = Msg.Mode.RUN;
        otherwise
          % nothing
      end
    end
  end
  
  methods (Access = private)
    function processInbox(this, inbox)
      [type, id, pb] = Msg.Proto.unpack(inbox);
      switch(type)
        case 'msg.Ack'
          if(~strcmp(id, this.remoteControl)) % ignore remote control
            n = find(strcmp(id, this.appAckID), 1, 'first');
            if(isempty(n))
              this.appAckID{end+1} = id;
              this.appAckMode(end+1) = pbGetMsgMode(pb);
              this.appAckTick(end+1) = this.tick();
            else
              this.appAckMode(n) = pbGetMsgMode(pb);
              this.appAckTick(n) = this.tick();
            end
          end
        case 'msg.Cmd'
          if(strcmp(id, this.remoteControl))
            this.cmdRequest = pbGetMsgMode(pb);
          end
        case 'nav.FusedState'
          if(strcmp(id, this.ownID))
            this.own = pb;
            this.ownInit = true;
          elseif(strcmp(id, this.targetID))
            this.target = pb;
            this.targetInit = true;
          end
        case 'nav.Mission'
          this.missionRequest = pbGetBehavior(pb);
        otherwise
          % nothing
      end
    end
    
    function sendAll(this)
      this.sendAck();
      this.sendMission();
      this.sendCmd();
      this.log('cmd=%s mission={%s,%s}', char(this.cmdMode), char(this.missionRequest), char(this.missionBehavior));
    end

    function sendAck(this)
      % Send ack for the remote control.
      msgAck = msg.AckBuilder();
      pbSetMsgMode(msgAck, this.cmdRequest);
      this.send(Msg.Proto.pack('msg.Ack', this.remoteControl, msgAck));
    end
    
    function sendMission(this)
      % Send mission.
      mission = nav.MissionBuilder();
      pbSetBehavior(mission, this.missionBehavior);
      this.send(Msg.Proto.pack('nav.Mission', this.msgAppID, mission));
    end
    
    function sendCmd(this)
      % Send command to each app.
      msgCmd = msg.CmdBuilder();
      pbSetMsgMode(msgCmd, this.cmdMode);
      for n = 1:numel(this.appAckID)
        this.send(Msg.Proto.pack('msg.Cmd', this.appAckID{n}, msgCmd));
      end
    end
  end
end
