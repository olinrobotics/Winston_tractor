% An application that displays all messages published to a connected switch.
classdef ARDListener < Msg.App
  properties (GetAccess = private, SetAccess = private)
    hFig;
  end
  
  methods (Access = public)
    function this = ARDListener()
      cfg = JSONRead('guard.json');
      this = this@Msg.App(mfilename('class'), cfg.fastTick);
      this.maxDisplay = cfg.maxDisplay;
    end
    
    function sub = topics(this) %#ok unused input
      sub = {''}; % subscribe to all topics
    end
    
    function process(this, inbox)
      if(~isempty(inbox))
        [type, id, pb] = Msg.Proto.unpack(inbox);
        if(~isempty(type))
          fprintf('%s:', type);
          fprintf('%s;', id);
          switch(type)
            case 'msg.Time'
              fprintf('time=%.3f', pb.getTimeS());
            case 'msg.Log'
              fprintf('text=%s', char(pb.getText()));
            case {'msg.Cmd', 'msg.Ack'}
              fprintf('mode=%s', char(pb.getMode()));
            case 'nav.Ctrl'
              fprintf('u=[');
              for n = 1:pb.getURealCount()
                uReal = pb.getUReal(n-1);
                if(n==1)
                  fprintf('%+5.2f', uReal);
                else
                  fprintf(';%+5.2f', uReal);
                end
              end
              fprintf(']');
            case 'nav.Img'
              img = pbGetImg(pb);
              if(isempty(this.hFig))
                this.hFig = figure;
              end
              figure(this.hFig);
              imshow(img);
              drawnow;
            otherwise
              str = pbToText(pb);
              if(numel(str)>this.maxDisplay)
                fprintf('%s', str(1:this.maxDisplay));
                fprintf('...');
              else
                fprintf('%s', str);
              end
          end
          fprintf('\n');
        end
      end
    end
  end
  
  properties (GetAccess = private, SetAccess = private)
    maxDisplay;
  end
end
