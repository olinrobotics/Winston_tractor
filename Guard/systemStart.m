function systemStart(appName, subURI, pubURI)
local = fileparts(mfilename('fullpath'));
system([fullfile(local, appName), ' "', subURI, '" "', pubURI, '" &']);
end
