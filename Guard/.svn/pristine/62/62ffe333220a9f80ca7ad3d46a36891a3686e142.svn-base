function terminalStart(appName, subURI, pubURI)
if(ismac)
  system(['/usr/X11/bin/xterm -hold -e ', fullfile(pwd, appName), ' "', subURI, '" "', pubURI, '" &']);
else
  system(['xterm -hold -e ', appName, ' "', subURI, '" "', pubURI, '" &']);
end
end
