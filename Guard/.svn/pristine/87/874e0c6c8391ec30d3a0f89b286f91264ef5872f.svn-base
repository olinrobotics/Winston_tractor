% Protocol tools.
%
% @see dependencies in README.txt
classdef Proto < handle
  properties (Constant = true, GetAccess = public)
    JAVAC = getJAVAC();
  end
  
  methods (Access = public, Static = true)
    function make(protoPath)
      % Build protocol interface.
      %
      % @param[in] protoPath optional path to folder containing {package}.proto files
      %
      % @note The package and java_outer_classname must be identical
      % @note Processes all files of the form {protoPath}/{package}.proto individually.
      % @note Places output in folders named {protoPath}/{package}.
      
      help('Msg.Proto');
      if(nargin==0)
        protoPath = pwd;
      end
      sysPath = getenv('PATH');
      if(isempty(strfind(sysPath, '/usr/local/bin')))
        sysPath = [sysPath, ':/usr/local/bin'];
        setenv('PATH', sysPath);
      end
      [status, PROTOC] = system('which protoc');
      if(status==0)
        PROTOC = PROTOC(1:(end-1));
      else
        error('Msg.Proto: Could not find protoc on this system.');
      end
      jarPath = fileparts(mfilename('fullpath'));
      jarFile = fullfile(jarPath, 'protobuf.jar');
      fileNames = dir(fullfile(protoPath, '*.proto'));
      for n = 1:numel(fileNames)
        [~, package] = fileparts(fileNames(n).name);
        outPath = fullfile(protoPath, package);
        if(exist(outPath, 'dir'))
          rmdir(outPath, 's');
        end
        mkdir(outPath);
        cmd = [PROTOC, ' -I"', protoPath, '" --cpp_out="', outPath, '" --java_out="',...
          outPath, '" "', fullfile(protoPath, fileNames(n).name), '"'];
        fprintf('%s\n', cmd);
        system(cmd);
        javaFile = [package, '.java']; % append java extension
        dest = fullfile(protoPath, package, javaFile);
        exposeNestedClasses(dest);
        cmd = [Msg.Proto.JAVAC, ' -classpath ', protoPath, ':', jarFile, ' ', dest];
        fprintf('%s\n', cmd);
        system(cmd);
      end
    end
    
    function addpath(protoPath)
      % Add protocol interface dependencies to the MATLAB path.
      %
      % @param[in] protoPath optional path to folder containing .proto files
      %
      % @note Call addpath() after make()
      if(nargin==0)
        protoPath = pwd;
      end
      jarPath = fileparts(mfilename('fullpath'));
      jarFile = fullfile(jarPath, 'protobuf.jar');
      if(ismember(jarFile, javaclasspath('-dynamic')))
        javarmpath(jarFile);
      end
      javaaddpath(jarFile);
      fileNames = dir(fullfile(protoPath, '*.proto'));
      for n = 1:numel(fileNames)
        [~, package] = fileparts(fileNames(n).name);
        outPath = fullfile(protoPath, package);
        if(ismember(outPath, javaclasspath('-dynamic')))
          javarmpath(outPath);
        end
        javaaddpath(outPath);
      end
    end
    
    function header = topic(type, id)
      % Assemble message header.
      %
      % @param[in]  type   message type as a string
      % @param[in]  id     extended identifier as a string
      % @param[out] header initial bytes of a message not including a terminating null character
      nc = char(0);
      header = type;
      if(~isempty(id))
        header = [header, nc, id];
      end
    end
    
    function flag = isTopic(message, header)
      % Determine whether the message matches the topic.
      %
      % @param[in]  messsage reference message
      % @param[in]  header   initial bytes to test against the message
      % @param[out] flag     true if all header bytes match the message
      assert(isa(message, 'char'));
      assert(isa(header, 'char'));
      flag = strncmp(char(message), char(header), numel(header));
    end
    
    function message = pack(type, id, pb)
      % Pack a message.
      %
      % @param[in]  type    message type as a string
      % @param[in]  id      extended identifier as a string
      % @param[in]  pb      protobuf to serialize
      % @param[out] message packed message as a string
      assert(isa(type, 'char'));
      assert(size(type, 1)<=1);
      assert(isa(id, 'char'));
      assert(size(id, 1)<=1);
      assert(isa(pb, 'com.google.protobuf.GeneratedMessage$Builder'));
      
      nc = char(0);
      message = [type, nc, id, nc];

      try
        data = pb.build().toByteArray();
        message = [message, char(typecast(data, 'uint8'))'];
      catch
        % nothing
      end
    end
    
    function [type, id, pb] = unpack(message)
      % Unpack a message.
      %
      % @param[in]  message packed message as a string
      % @param[out] type    message type as a string
      % @param[out] id      extended identifier as a string
      % @param[out] data    unserialized protobuf
      assert(isa(message, 'char'));
      assert(size(message, 1)<=1);
      
      nc = char(0);
      
      % get message size
      K = numel(message);
      
      % find first null character if present
      ka = K+1;
      for k = 1:K
        if(message(k)==nc)
          ka = k;
          break;
        end
      end
      
      % find second null character if present
      kb = K+1;
      for k = (ka+1):K
        if(message(k)==nc)
          kb = k;
          break;
        end
      end
      
      % check message format
      if((ka<=K)&&(kb<=K))
        type = message(1:(ka-1));
        id = message((ka+1):(kb-1));
        data = message((kb+1):K);
      else
        type = '';
        id = '';
        data = '';
      end

      % unpack message if possible
      try      
        eval(['pb=', type, 'Builder();']);
        pb = pb.mergeFrom(typecast(uint8(data'), 'int8')); %#ok defined on the previous line
      catch
        pb = msg.NullBuilder();
      end
    end
    
    function Test()
      % Unit test.
      Msg.Proto.make();
      Msg.Proto.addpath();
      testType = 'MyType';
      testID = 'MyID';
      testData = 'testing';
      pb = Msg.Proto.pack(testType, testID, testData);
      [type, id, data] = Msg.Proto.unpack(pb);
      fprintf('type = %s\n', type);
      fprintf('id = %s\n', id);
      fprintf('data = %s\n', data);
    end
  end
end

function jPath = getJAVAC()
if(ismac)
  if(verLessThan('matlab', '8.1'))
    jPath = '/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home/bin/javac';
  else
    jPath = '/System/Library/Frameworks/JavaVM.framework/Versions/1.7/Home/bin/javac';
  end
else
  if(verLessThan('matlab', '8.1'))
    jPath = '/usr/java/jdk1.6.0_65/bin/javac';
  else
    jPath = '/usr/java/jdk1.7.0_80/bin/javac';
  end
end
end

function exposeNestedClasses(fName)
cName = cell(0, 1);
fid = fopen(fName, 'r');
line = fgetl(fid);
while(ischar(line))
  trim = strfind(line, 'Construct using ');
  if(~isempty(trim))
    line = line((trim+16):end);
    trim = strfind(line, '.newBuilder()');
    if(~isempty(trim))
      cName{end+1} = line(1:(trim-1)); %#ok grows in loop
    end
  end
  line = fgetl(fid);
end
fclose(fid);
str = fileread(fName);
insertionKey = '  // @@protoc_insertion_point(outer_class_scope)';
point = strfind(str, insertionKey);
if(isempty(point))
  error('exposeNestedClasses: Could not find insertion point.');
end
fid = fopen(fName, 'w');
fprintf(fid, '%s', str(1:(point-1)));
% public static MyClass.Builder newMyClass() {return MyClass.newBuilder();}
for c = 1:numel(cName)
  fullName = cName{c};
  trim = find(fullName=='.', 1, 'last');
  innerName = fullName((trim+1):end);
  fprintf(fid, 'public static %s', fullName);
  fprintf(fid, '.Builder %sBuilder', innerName);
  fprintf(fid, '() {return %s', fullName);
  fprintf(fid, '.newBuilder();}\n');
end
fprintf(fid, '%s', str((point+numel(insertionKey)):end));
fclose(fid);
end
