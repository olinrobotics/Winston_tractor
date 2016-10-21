function pbSetMsgMode(pb, msgMode)
persistent OFF IDLE RUN
if(isempty(OFF))
  OFF = javaMethod('valueOf', 'msg$Mode', 'OFF');
  IDLE = javaMethod('valueOf', 'msg$Mode', 'IDLE');
  RUN = javaMethod('valueOf', 'msg$Mode', 'RUN');
end
if(~isa(msgMode, 'msg$Mode'))
  switch(uint8(msgMode))
    case uint8(Msg.Mode.IDLE)
      msgMode = IDLE;
    case uint8(Msg.Mode.RUN)
      msgMode = RUN;
    otherwise
      msgMode = OFF;
  end
end
pb.setMode(msgMode);
end
