function name = getHostName()
[ret, name] = system('hostname');   
if(ret~=0)
   if(ispc)
      name = getenv('COMPUTERNAME');
   else      
      name = getenv('HOSTNAME');      
   end
end
name = strtok(strtrim(lower(name)), '.');
end
