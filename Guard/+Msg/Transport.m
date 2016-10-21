% Message transport middleware.
%
% @see dependencies in README.txt
classdef Transport < handle
  properties (Constant = true, GetAccess = public)
    LINGER = 0; % maximum number of milliseconds to hold delayed messages after socket is closed
    RCVHWM = 10000; % maximum number of delayed incoming messages to hold
    SNDHWM = 10000; % maximum number of delayed outgoing messages to hold
  end
  
  properties (GetAccess = private, SetAccess = private)
    subURI
    pubURI
    pubBind
    maxLength
    context
    subSocket
    pubSocket
  end
  
  methods (Access = public, Static = true)
    function make()
      % Build transport layer interface.
      help('Msg.Transport');
      base = fullfile(fileparts(mfilename('fullpath')), 'matlab-zmq');
      src = fullfile(base, 'lib', '+zmq');
      build = fullfile(src, '+core');
      dest = fileparts(fileparts(mfilename('fullpath')));
      if(ispc)
        run(fullfile(base, 'config_win.m')); % loads variables
      elseif(ismac)
        run(fullfile(base, 'config_mac.m')); % loads variables
      else
        run(fullfile(base, 'config_unix.m')); % loads variables
      end
      run(fullfile(base, 'make.m'));
      copyfile(src, fullfile(dest, '+zmq'));
      files = dir(fullfile(build, ['*.', mexext]));
      for n = 1:numel(files)
        delete(fullfile(build, files(n).name));
      end
    end
  end
  
  methods (Access = public)
    function this = Transport(subURI, pubURI, maxLength, pubBind)
      % Construct transport layer object.
      %
      % @param[in] subURI    subscrbing endpoint address
      % @param[in] pubURI    publishing endpoint address
      % @param[in] maxLength (optional) maximum length of received message (will be truncated)
      % @param[in] pubBind   (optional) bind to the publishing address
      this.subURI = subURI;
      this.pubURI = pubURI;
      if(nargin>=3)
        this.maxLength = maxLength;
      else
        this.maxLength = 67108864;
      end
      if(nargin>=4)
        this.pubBind = pubBind;
      else
        this.pubBind = false;
      end
      
      % add ZMQ dependency to the path
      addpath(fileparts(fileparts(mfilename('fullpath'))));
      
      try
        this.context = zmq.core.ctx_new();
      catch
        this.cleanup();
        error('Msg.Transport: Failed to create transport layer context.');
      end
      
      try
        this.pubSocket = zmq.core.socket(this.context, 'ZMQ_PUB');
        zmq.core.setsockopt(this.pubSocket, 'ZMQ_LINGER', this.LINGER);
        zmq.core.setsockopt(this.pubSocket, 'ZMQ_SNDHWM', this.SNDHWM);
      catch
        this.cleanup();
        error('Msg.Transport: Failed to open PUB socket.');
      end
      
      try
        if(this.pubBind)
          zmq.core.bind(this.pubSocket, this.pubURI);
        else
          zmq.core.connect(this.pubSocket, this.pubURI);
        end
      catch
        this.cleanup();
        error('Msg.Transport: Failed to connect to PUB socket.');
      end
      
      try
        this.subSocket = zmq.core.socket(this.context, 'ZMQ_SUB');
        zmq.core.setsockopt(this.subSocket, 'ZMQ_LINGER', this.LINGER);
        zmq.core.setsockopt(this.subSocket, 'ZMQ_RCVHWM', this.RCVHWM);
      catch
        this.cleanup();
        error('Msg.Transport: Failed to open SUB socket.');
      end
      
      try
        zmq.core.connect(this.subSocket, this.subURI);
      catch
        this.cleanup();
        error('Msg.Transport: Failed to connect to SUB socket.');
      end
      
      % solve slow joiner problem
      this.subscribe(char(0));
      while(true)
        this.send(char(0));
        pause(0.1);
        message = this.receive();
        if(numel(message)>0)
          this.unsubscribe(char(0));
          break;
        end
      end
    end
    
    function subscribe(this, header)
      % Subscribe to messages that match header.
      %
      % @param[in] header initial bytes to match
      assert(isa(header, 'char'));
      assert(size(header, 1)<=1);
      zmq.core.setsockopt(this.subSocket, 'ZMQ_SUBSCRIBE', header);
    end
    
    function unsubscribe(this, header)
      % Unsubscribe to messages that match header.
      %
      % @param[in] header initial bytes to match
      assert(isa(header, 'char'));
      assert(size(header, 1)<=1);
      zmq.core.setsockopt(this.subSocket, 'ZMQ_UNSUBSCRIBE', header);
    end
    
    function send(this, msg)
      % Send message (non-blocking).
      %
      % @param[in] msg byte array to send
      assert(isa(msg, 'char'));
      assert(size(msg, 1)<=1);
      zmq.core.send(this.pubSocket, uint8(msg));
    end
    
    function msg = receive(this)
      % Receive message (non-blocking).
      %
      % @param[out] msg received byte array
      %
      % @note If a message is available, then it will be received in its entirety.
      % @note If no message is available, then the output will be an empty string.
      msg = zmq.core.recv(this.subSocket, this.maxLength, 'ZMQ_DONTWAIT');
      if(isa(msg, 'uint8'))
        msg = char(msg);
      else
        msg = '';
      end
    end
    
    function cleanup(this)
      % Cleanup transport layer dependencies.
      [~, mexList] = inmem('-completenames');
      dest = fileparts(fileparts(mfilename('fullpath')));
      mexSocketFile = fullfile(dest, '+zmq', '+core', ['socket.', mexext]);
      mexCtxFile = fullfile(dest, '+zmq', '+core', ['ctx_new.', mexext]);
      
      if(~isempty(this.subSocket))
        if(ismember(mexSocketFile, mexList))
          zmq.core.close(this.subSocket); % safer than disconnecting (possible matlab-zmq bug)
        end
        this.subSocket = [];
      end
      
      if(~isempty(this.pubSocket))
        if(ismember(mexSocketFile, mexList))
          zmq.core.close(this.pubSocket); % safer than disconnecting (possible matlab-zmq bug)
        end
        this.pubSocket = [];
      end
      
      if(~isempty(this.context))
        if(ismember(mexCtxFile, mexList))
          zmq.core.ctx_term(this.context);
        end
        this.context = [];
      end
    end
    
    function delete(this)
      % Delete transport layer object.
      this.cleanup();
    end
  end
end
