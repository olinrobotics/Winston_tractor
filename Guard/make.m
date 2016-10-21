function make(target)
if(nargin==0)
  target = 'all';
end
local = fileparts(mfilename('fullpath'));
switch(target)
  case 'all'
    make('proto');
    make('+Msg');
    make('ARD');
    make('OC');
    make('UW');
    make('+zmq');
    make('guard');
  case 'guard'
    system('make guard');
  case 'proto'
    Msg.Proto.make(local);
  case '+zmq'
    Msg.Transport.make();    
  case 'clean'
    system(['make -C ', local, ' clean']);
    command = ['rm -Rf ', fullfile(local, '+zmq')];
    fprintf('%s\n', command);
    system(command);
  otherwise
    system(['make -C ', fullfile(local, target)]);
end
end
