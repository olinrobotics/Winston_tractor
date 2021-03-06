% Launches applications triggered by timer callbacks.
classdef Exec < handle
  properties (GetAccess = private, SetAccess = private)
    msgTimeWarp
    msgApp
    msgComms
    msgAppTimer
    msgCommsTimer
  end
  
  methods (Access = public, Static = true)
    function this = getInstance(msgTimeWarp)
      % Get singleton instance.
      %
      % @param[in] msgTimeWarp time scaling parameter
      persistent msgExecSingleton
      if(~isa(msgExecSingleton, 'Msg.Exec'))
        msgExecSingleton = Msg.Exec(msgTimeWarp);
      end
      if(~isvalid(msgExecSingleton))
        msgExecSingleton = Msg.Exec(msgTimeWarp);
      end
      this = msgExecSingleton;
    end
  end
  
  methods (Access = public)
    function delete(this)
      % Destructor
      %
      % @note Does not delete apps.
      
      % stop and delete app timers
      for k = 1:numel(this.msgAppTimer)
        stop(this.msgAppTimer{k});
        delete(this.msgAppTimer{k});
      end
      this.msgAppTimer = cell(0, 1);
      
      % stop and delete com timers
      for k = 1:numel(this.msgCommsTimer)
        stop(this.msgCommsTimer{k});
        delete(this.msgCommsTimer{k});
      end
      this.msgCommsTimer = cell(0, 1);
      
      % clear the timer queue
      drawnow;
      
      % delete com connections
      for k = 1:numel(this.msgComms)
        this.msgComms{k}.delete();
      end
      this.msgComms = cell(0, 1);
      
      % clear app handles
      this.msgApp = cell(0, 1);
    end
    
    function start(this, msgApp, subURI, pubURI, pubBind)
      % Start application.
      %
      % @param[in] msgApp  message application instance
      % @param[in] subURI  subscrbe endpoint
      % @param[in] pubURI  publish endpoint
      % @param[in] pubBind (optional) bind to the publish endpoint
      if(nargin<5)
        pubBind = false;
      end
      msgTimerMin = 0.001; % @see timer documentation
      msgTimerMax = double(intmax('int32')-1)/1000.0; % @see timer documentation
      commsTick = min(max(msgApp.msgCommsTick/this.msgTimeWarp, msgTimerMin), msgTimerMax);
      appTick = min(max(msgApp.msgAppTick/this.msgTimeWarp, msgTimerMin), msgTimerMax);
      nApp = numel(this.msgApp)+1;
      this.msgApp{nApp} = msgApp;
      this.msgAppTimer{nApp} = timer('TimerFcn', {@Msg.Exec.msgAppTimerCallback, nApp}, 'Period', appTick,...
        'StartDelay', appTick, 'ExecutionMode', 'fixedSpacing', 'BusyMode', 'queue');
      this.msgCommsTimer{nApp} = timer('TimerFcn', {@Msg.Exec.msgCommsTimerCallback, nApp}, 'Period', commsTick,...
        'StartDelay', commsTick, 'ExecutionMode', 'fixedRate', 'BusyMode', 'queue');
      this.msgComms{nApp} = Msg.Transport(subURI, pubURI, msgApp.msgMaxLength, pubBind);
      
      % set subscriptions
      msgTopics = this.msgApp{nApp}.msgTopics();
      for iTopic = 1:numel(msgTopics)
        this.msgComms{nApp}.subscribe(msgTopics{iTopic});
      end
      
      % start app timer
      start(this.msgAppTimer{nApp});
      
      % start com timer
      start(this.msgCommsTimer{nApp});
    end
  end
  
  methods (Access = private)
    function this = Exec(msgTimeWarp)
      this.msgTimeWarp = msgTimeWarp;
      this.msgApp = cell(0, 1);
      this.msgComms = cell(0, 1);
      this.msgAppTimer = cell(0, 1);
      this.msgCommsTimer = cell(0, 1);
    end
  end
  
  methods (Access = public, Static = true)
    function msgAppTimerCallback(~, ~, nApp)
      % safe execution
      try

        % get message executive
        this = Msg.Exec.getInstance(1.0);

        % if message executive is valid
        if(isa(this, 'Msg.Exec')&&isvalid(this))

          % if the application index is valid (handles shutdown case)
          if(nApp<=numel(this.msgApp))
            
            % call the application with an empty inbox
            this.msgApp{nApp}.msgProcess('');

            % send outgoing messages
            for iOutbox = 1:numel(this.msgApp{nApp}.msgOutbox)
              this.msgComms{nApp}.send(this.msgApp{nApp}.msgOutbox{iOutbox});
            end

            % clear the outbox
            this.msgApp{nApp}.msgClear();
          end
        end
        
        % handle error
      catch err
        fprintf('Msg.Exec:ERROR:%s\n', err.message);
      end
    end
    
    function msgCommsTimerCallback(~, ~, nApp)
      % safe execution
      try
        
        % get message executive
        this = Msg.Exec.getInstance(1.0);
        
        % if message executive is valid
        if(isa(this, 'Msg.Exec')&&isvalid(this))
          
          % if the application index is valid (handles shutdown case)
          if(nApp<=numel(this.msgApp))
          
            % loop until inbox is empty
            while(true)

              % receive incoming message
              inbox = this.msgComms{nApp}.receive();

              % if inbox is empty
              if(isempty(inbox))

                % stop receiving
                break;

              else % inbox is not empty

                % call the application
                this.msgApp{nApp}.msgProcess(inbox);

                % send outgoing messages
                for iOutbox = 1:numel(this.msgApp{nApp}.msgOutbox)
                  this.msgComms{nApp}.send(this.msgApp{nApp}.msgOutbox{iOutbox});
                end

                % clear the outbox
                this.msgApp{nApp}.msgClear();
              end
            end
          end
        end
        
        % handle error
      catch err
        fprintf('Msg.Exec:ERROR:%s\n', err.message);
      end
    end
  end
end
