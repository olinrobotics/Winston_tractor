classdef Camera < FlightGear.Base  
  properties (GetAccess = private, SetAccess = private)
    httpdPort
    curlBusy
  end
  
  methods (Access = private, Static = true)
    function putFiles(AltF)
      % Put vehicle models into FlightGear directory (requires write access).
      cfg = FlightGear.Config();
      src = fileparts(mfilename('fullpath'));
      dest{1} = fullfile(cfg.root, 'Aircraft');
      dest{2} = fullfile(cfg.root, 'AI', 'Aircraft');
      for d = 1:numel(dest)
        if(AltF<=cfg.spaceAltitude)
          FlightGear.Base.mkcpy(src, dest{d}, 'Camera');
        else
          FlightGear.Base.mkcpy(src, dest{d}, 'SpaceCamera');
        end
      end
      FlightGear.Base.mkcpy(src, cfg.root, 'Protocol');
    end
  end
  
  methods (Access = public)
    function this = Camera(portList, LatD, LonD, AltF, varargin)
      % Construct FlightGear Camera object (after constructing Target objects).
      %
      % @param[in] portList Target ports (cell array of strings)
      % @param[in] LatD     initial geodetic latitude in degrees
      % @param[in] LonD     initial longitude in degrees
      % @param[in] AltF     initial altitude above the WGS84 ellipsoid in feet
      % @param[in] RollD    initial roll in degrees
      % @param[in] PitchD   initial pitch in degrees
      % @param[in] YawD     initial yaw in degrees
      FlightGear.Camera.putFiles(AltF);
      this = this@FlightGear.Base(LatD, LonD, AltF, varargin{:});
      this.httpdPort = FlightGear.Base.nextPort(this.multiPortRange);
      if(AltF<=this.spaceAltitude)
        aircraft = 'Camera';
      else
        aircraft = 'SpaceCamera';
      end
      %hfovR = str2double(this.hfov)*math.DEGTORAD;
      %vfovR = convertFoV(hfovR, str2double(this.strides), str2double(this.steps));
      %vfovD = num2str(vfovR*math.RADTODEG, '%16.9f');
      param = [this.common,...
        ' --geometry=', this.strides, 'x', this.steps,...
        ' --visibility="', this.visibility, '"',...
        ' --wind=', this.wind,...
        ' --fog-nicest',...
        ' --disable-clouds',...
        ' --enable-clouds3d',...
        ' --enable-terrasync',...
        ' --terrasync-dir="', this.terrasync, '"',...
        ' --start-date-lat=', this.localtime,...
        ' --texture-filtering=', this.antialiasing,...
        ' --httpd=', this.httpdPort,...
        ' --multiplay=in,', this.hz, ',', this.host, ',' , this.multiPortRange,...
        ' --callsign=N100US',...
        ' --aircraft=', aircraft,...
        ' --prop:/sim/current-view/field-of-view=', this.hfov,...
        ' --prop:/sim/current-view/goal-heading-offset-deg=0',...
        ' --prop:/sim/rendering/static-lod/ai-detailed=4',...
        ' --prop:/sim/rendering/shaders/skydome=true',...
        ' --prop:/environment/air-pollution-norm=', this.pollution];
      for iTarget = 1:numel(portList)
        param = [param, ' --multiplay=out,', this.hz, ',', this.host, ',', portList{iTarget}]; %#ok grows in loop
      end
      this.open(param);
      this.curlBusy = false;
    end
    
    function [success, img] = pollImage(this, fName)
      % Poll for a new image from framebuffer.
      %
      % @param[in]  fName   (optional) save file to the specified file name
      % @param[out] success true if an image is available
      % @param[out] img     new image or empty if no new image is available
      %
      % @note Does not start acquiring an image while FlightGear is busy.
      persistent fDefault
      if(isempty(fDefault))
        fDefault = [hidi.getHostName(), '.screenshot.png'];
      end
      doSave = (nargin>=2);
      doRead = (nargout>=2);
      if(~doSave)
        fName = fDefault;
      end
      img = zeros(0, 1, 'uint8');
      success = false;
      if(~this.isBusy())
        if(this.curlBusy)
          if(exist(fName, 'file'))
            fid = fopen(fName, 'r');
            if(fid~=-1)
              fclose(fid);
              if(doRead)
                img = imread(fName);
              end
              if(~doSave)
                delete(fName);
              end
              success = true;
              this.curlBusy = false;
            end
          end
        else
          if(exist(fName, 'file'))
            delete(fName);
          end
          cmd = ['curl --silent -o ''', fName, ''' ''http://', this.host, ':', num2str(this.httpdPort),...
            '/screenshot?type=png'' &'];
          status = system(cmd);
          this.curlBusy = ~status;
        end
      end
    end
    
    function delete(this) %#ok unused argument
      % Destructor.
      if(ispc)
        cmd = 'Taskkill /F /IM fgfs.exe';
      else
        cmd = 'killall -9 fgfs';
      end
      system(cmd);
    end
  end
end

% Convert vertical or horizontal field of view to the other.
%
% @param[in] fieldOfViewR     field of view in radians
% @param[in] pixParallel      number of pixels in the direction of the given vield of view
% @param[in] pixPerpendicular number of pixels in the direction perpendicular to the given field of view
function fieldOfViewR = convertFoV(fieldOfViewR, pixParallel, pixPerpendicular)
fieldOfViewR = 2.0*atan2(tan(fieldOfViewR/2.0)*pixPerpendicular, pixParallel);
end
