classdef Target < FlightGear.Base  
  methods (Access = private, Static = true)
    function putFiles(aircraft)
      % Put vehicle models into FlightGear directory (requires write access).
      cfg = FlightGear.Config();
      src = fileparts(mfilename('fullpath'));
      dest{1} = fullfile(cfg.root, 'Aircraft');
      dest{2} = fullfile(cfg.root, 'AI', 'Aircraft');
      for d = 1:numel(dest)
        FlightGear.Base.mkcpy(src, dest{d}, aircraft);
      end
    end
  end
  
  methods (Access = public)
    function this = Target(port, aircraft, callsign, LatD, LonD, AltF, varargin)
      % Construct FlightGear Target object (prior to constructing the Camera object).
      %
      % @param[in] port     Camera port (string)
      % @param[in] aircraft aircraft model identifier (see list of model subdirectories in this package)
      % @param[in] callsign unique callsign (string)
      % @param[in] LatD     initial geodetic latitude in degrees
      % @param[in] LonD     initial longitude in degrees
      % @param[in] AltF     initial altitude above the WGS84 ellipsoid in feet
      % @param[in] RollD    initial roll in degrees
      % @param[in] PitchD   initial pitch in degrees
      % @param[in] YawD     initial yaw in degrees
      FlightGear.Target.putFiles(aircraft);
      this = this@FlightGear.Base(LatD, LonD, AltF, varargin{:});
      param = [this.common,...
        ' --geometry=64x64',...
        ' --fog-disable',...
        ' --disable-specular-highlight',...
        ' --disable-enhanced-lighting',...
        ' --enable-wireframe',...
        ' --disable-clouds',...
        ' --disable-clouds3d',...
        ' --multiplay=out,', this.hz, ',', this.host, ',', this.multiPortRange,...
        ' --multiplay=in,', this.hz, ',', this.host, ',' , port,...
        ' --callsign=', callsign,...
        ' --aircraft=', aircraft,...
        ' --prop:/sim/sceneryloaded-override=1',...
        ' --prop:/sim/rendering/draw-mask/terrain=0',...
        ' --prop:/sim/rendering/draw-mask/clouds=0'];
      this.open(param);
    end
  end
end
