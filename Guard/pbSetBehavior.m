function pbSetBehavior(pb, behavior)
persistent LOITER APPROACH CAPTURE RELEASE DEPART
if(isempty(LOITER))
  LOITER = javaMethod('valueOf', 'nav$Behavior', 'LOITER');
  APPROACH = javaMethod('valueOf', 'nav$Behavior', 'APPROACH');
  CAPTURE = javaMethod('valueOf', 'nav$Behavior', 'CAPTURE');
  RELEASE = javaMethod('valueOf', 'nav$Behavior', 'RELEASE');
  DEPART = javaMethod('valueOf', 'nav$Behavior', 'DEPART');
end
if(~isa(behavior, 'nav$Behavior'))
  switch(uint8(behavior))
    case uint8(Behavior.APPROACH)
      behavior = APPROACH;
    case uint8(Behavior.CAPTURE)
      behavior = CAPTURE;
    case uint8(Behavior.RELEASE)
      behavior = RELEASE;
    case uint8(Behavior.DEPART)
      behavior = DEPART;
    otherwise
      behavior = LOITER;
  end
end
pb.setBehavior(behavior);
end
