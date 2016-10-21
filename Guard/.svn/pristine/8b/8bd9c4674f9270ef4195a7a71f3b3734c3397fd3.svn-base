classdef Base < FlightGear.Config
  properties (GetAccess = protected, SetAccess = private)
    common
    propsPort
    genericPort
    genericSock
    generic
    tBusy
    dtReady
  end
  
  methods (Access = public, Static = true)
    function port = nextPort(multiPortRange)
      persistent p
      if(isempty(p))
        p = str2double(multiPortRange);
      end
      p = p+1;
      port = num2str(p);
    end
    
    function sendUDP(host, port, message)
      import java.io.*
      import java.net.DatagramSocket
      import java.net.DatagramPacket
      import java.net.InetAddress
      addr = InetAddress.getByName(host);
      packet = DatagramPacket(message, length(message), addr, str2double(port));
      socket = DatagramSocket();
      socket.setReuseAddress(1);
      socket.send(packet);
      socket.close();
    end
    
    function mkcpy(src, dest, folder)
      srcFolder = fullfile(src, folder);
      destFolder = fullfile(dest, folder);
      if(~exist(srcFolder, 'dir'))
        error('FlightGear: Unrecognized aircraft model: %s', srcFolder);
      end
      if(exist(destFolder, 'dir'))
        rmdir(destFolder, 's');
      end
      mkdir(destFolder);
      copyfile(fullfile(src, folder, '*'), destFolder, 'f');
    end
  end
  
  methods (Access = public)
    function this = Base(LatD, LonD, AltF, RollD, PitchD, YawD)
      % Constructor.
      if(nargin<6)
        YawD = 0.0;
      end
      if(nargin<5)
        PitchD = 0.0;
      end
      if(nargin<4)
        RollD = 0.0;
      end
      this = this@FlightGear.Config();
      this.propsPort = FlightGear.Base.nextPort(this.multiPortRange);
      this.genericPort = FlightGear.Base.nextPort(this.multiPortRange);
      this.common = [' --fg-root="', this.root, '"',...
        ' --fg-scenery="', this.scenery, '"',...
        ' --generic=socket,in,', this.hz, ',', this.host, ',' , this.genericPort, ',udp,llarpy',...
        ' --props=', this.propsPort,...
        ' --lat=', num2str(LatD),...
        ' --lon=', num2str(LonD),...
        ' --altitude=', num2str(AltF),...
        ' --roll=', num2str(RollD),...
        ' --pitch=', num2str(PitchD),...
        ' --heading=', num2str(YawD),...
        ' --uBody=0',...
        ' --vBody=0',...
        ' --wBody=0',...
        ' --vc=0',...
        ' --mach=0',...
        ' --glideslope=0',...
        ' --roc=0',...
        ' --turbulence=0',...
        ' --fdm=null',...
        ' --notrim',...
        ' --disable-panel',...
        ' --disable-hud',...
        ' --disable-random-objects',...
        ' --disable-ai-traffic',...
        ' --disable-sound',...
        ' --disable-splash-screen',...
        ' --disable-real-weather-fetch',...
        ' --disable-horizon-effect',...
        ' --disable-fgcom',...
        ' --prop:/sim/frame-rate-throttle-hz=', this.hz,...
        ' --prop:/sim/model-hz=', this.hz,...
        ' --prop:/sim/multiplay/transmission-freq-hz=', this.hz,...
        ' --prop:/sim/menubar/visibility=false',...
        ' --prop:/sim/hud/visibility=false',...
        ' --prop:/environment/config/enabled=0',...
        ' --prop:/sim/ati-viewport-hack=0'];
    end
    
    function open(this, param)
      if(ispc)
        cmd = ['start /B "FlightGear" "', fullfile(this.bin, 'fgfs.exe'), '"', param];
      else
        lib = '/lib64:';
        LD_LIBRARY_PATH = getenv('LD_LIBRARY_PATH');
        if(~strncmp(LD_LIBRARY_PATH, lib, numel(lib)))
          setenv('LD_LIBRARY_PATH', [lib, LD_LIBRARY_PATH]);
        end
        cmd = [fullfile(this.bin, 'fgfs'), param, ' &'];
      end
      if(this.verbose)
        fprintf('%s\n', cmd);
      end
      system(cmd);
      this.tBusy = tic;
      this.dtReady = this.delayStart+this.delaySync;
    end
    
    function flag = isBusy(this)
      flag = (toc(this.tBusy)<this.dtReady);
    end
    
    function success = setLLARPY(this, LatD, LonD, AltF, RollD, PitchD, YawD)
      % Set object position and orientation.
      %
      % @param[in] LatD   geodetic latitude in degrees
      % @param[in] LonD   longitude in degrees
      % @param[in] AltF   altitude above the WGS84 ellipsoid in feet
      % @param[in] RollD  roll about north axis in degrees
      % @param[in] PitchD pitch about east axis in degrees
      % @param[in] YawD   yaw about down axis in degrees
      if(toc(this.tBusy)>=1.0/str2double(this.hz))
        PitchD = max(min(PitchD, 89.999), -89.999);
        FlightGear.Base.sendUDP(this.host, this.genericPort, int8(sprintf(...
          '%20.16f,%20.16f,%20.16f,%20.16f,%20.16f,%20.16f,%20.16f,0,0,0,0,0,0,0,0,0\r\n',...
          LatD, LonD, AltF, RollD, PitchD, YawD, YawD)));
        this.tBusy = tic;
        this.dtReady = 1.0; % ready for image acquisition
        success = true;
      else
        success = false;
      end
    end
    
    function setprop(this, key, value)
      import java.net.InetAddress
      import java.net.Socket
      import java.io.*
      addr = InetAddress.getByName(this.host);
      socket = Socket(addr, str2double(this.propsPort));
      out = PrintWriter(socket.getOutputStream(), true);
      out.println(sprintf('set %s %s\r\n', key, value));
      out.close();
      socket.close();
    end
    
    function GroundF = getElevation(this)
      % Get ground elevation below the vehicle.
      GroundF = this.getDouble('/position/ground-elev-ft');
    end
    
    function value = getDouble(this, key)
      % Get parameter as double.
      value = str2double(this.getString(key));
    end
    
    function value = getString(this, key)
      % Get parameter as string.
      import java.net.Socket
      import java.io.*
      propsSock = Socket(this.host, str2double(this.propsPort));
      in = BufferedReader(InputStreamReader(propsSock.getInputStream()));
      out = PrintWriter(propsSock.getOutputStream(), true);
      out.println(sprintf(['get ', key, '\r\n']));
      s = char(in.readLine());
      j = strfind(s, '''');
      value = s(j(1)+1:j(2)-1);
      in.close();
      out.close();
      propsSock.close();
    end

%     function openSocket(this)
%       import java.net.Socket
%       import java.io.*
%       for attempt = 1:this.attemptMax
%         if(attempt==this.attemptMax)
%           error('FlightGear.Base: Timeout while waiting for FlightGear to start.');
%         end
%         try
%           this.propsSock = Socket(this.host, str2double(this.propsPort));
%           break;
%         catch
%           pause(0.1);
%         end
%       end
%       this.in = BufferedReader(InputStreamReader(this.propsSock.getInputStream()));
%       this.out = PrintWriter(this.propsSock.getOutputStream(), true);
%     end
%     
%     function [LatD, LonD, AltF] = getLLA(this)
%       % Get position in LLA.
%       LatD = this.getDouble('/position/latitude-deg');
%       LonD = this.getDouble('/position/longitude-deg');
%       AltF = this.getDouble('/position/altitude-ft');
%     end
%     
%     function [RollD, PitchD, YawD] = getRPY(this)
%       % Get orientation in RPY.
%       RollD = this.getDouble('/orientation/roll-deg');
%       PitchD = this.getDouble('/orientation/pitch-deg');
%       YawD = this.getDouble('/orientation/heading-deg');
%     end
%     
%     function [NorthRateFPS, EastRateFPS, DownRateFPS] = getVelocity(this)
%       % Get velocity.
%       NorthRateFPS = this.getDouble('/velocities/speed-north-fps');
%       EastRateFPS = this.getDouble('/velocities/speed-east-fps');
%       DownRateFPS = this.getDouble('/velocities/speed-down-fps');
%     end
%     
%     function setLLA(this, LatD, LonD, AltF)
%       % Set position in LLA.
%       this.setDouble('/position/latitude-deg', LatD);
%       this.setDouble('/position/longitude-deg', LonD);
%       this.setDouble('/position/altitude-ft', AltF);
%     end
%     
%     function setRPY(this, RollD, PitchD, YawD)
%       % Set orientation in RPY.
%       this.setDouble('/orientation/roll-deg', RollD);
%       this.setDouble('/orientation/pitch-deg', PitchD);
%       this.setDouble('/orientation/heading-deg', YawD);
%     end
%     
%     function setVelocity(this, NorthRateFPS, EastRateFPS, DownRateFPS)
%       % Set velocity.
%       this.setDouble('/velocities/speed-north-fps', NorthRateFPS);
%       this.setDouble('/velocities/speed-east-fps', EastRateFPS);
%       this.setDouble('/velocities/speed-down-fps', DownRateFPS);
%     end
%     
%     function setDouble(this, key, value)
%       % Set parameter as double.
%       this.setString(key, sprintf('%20.16f', value));
%     end
%     
%     function setString(this, key, value)
%       % Set parameter as string.
%       this.out.printf('set %s %s\r\n', key, value);
%       this.in.readLine(); % TODO: use a better method to clear the input
%     end
  end
end
