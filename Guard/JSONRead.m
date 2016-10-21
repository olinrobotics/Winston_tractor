function cfg = JSONRead(fName)
persistent cfgCache
if(isempty(cfgCache))
  cfgCache = containers.Map;
end
if(~cfgCache.isKey(fName))
  cfgCache(fName) = loadjson(fName);
end
  cfg = cfgCache(fName);
end

% LICENSE_BSD.txt
%
% Copyright 2011-2015 Qianqian Fang <fangq at nmr.mgh.harvard.edu>. All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without modification, are
% permitted provided that the following conditions are met:
% 
%    1. Redistributions of source code must retain the above copyright notice, this list of
%       conditions and the following disclaimer.
% 
%    2. Redistributions in binary form must reproduce the above copyright notice, this list
%       of conditions and the following disclaimer in the documentation and/or other materials
%       provided with the distribution.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND ANY EXPRESS OR IMPLIED
% WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS 
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
% ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
% The views and conclusions contained in the software and documentation are those of the
% authors and should not be interpreted as representing official policies, either expressed
% or implied, of the copyright holders.

function data = loadjson(fname,varargin)
%
% data=loadjson(fname,opt)
%    or
% data=loadjson(fname,'param1',value1,'param2',value2,...)
%
% parse a JSON (JavaScript Object Notation) file or string
%
% authors:Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% created on 2011/09/09, including previous works from 
%
%         Nedialko Krouchev: http://www.mathworks.com/matlabcentral/fileexchange/25713
%            created on 2009/11/02
%         François Glineur: http://www.mathworks.com/matlabcentral/fileexchange/23393
%            created on  2009/03/22
%         Joel Feenstra:
%         http://www.mathworks.com/matlabcentral/fileexchange/20565
%            created on 2008/07/03
%
% $Id$
%
% input:
%      fname: input file name, if fname contains "{}" or "[]", fname
%             will be interpreted as a JSON string
%      opt: a struct to store parsing options, opt can be replaced by 
%           a list of ('param',value) pairs - the param string is equivallent
%           to a field in opt. opt can have the following 
%           fields (first in [.|.] is the default)
%
%           opt.SimplifyCell [0|1]: if set to 1, loadjson will call cell2mat
%                         for each element of the JSON data, and group 
%                         arrays based on the cell2mat rules.
%           opt.FastArrayParser [1|0 or integer]: if set to 1, use a
%                         speed-optimized array parser when loading an 
%                         array object. The fast array parser may 
%                         collapse block arrays into a single large
%                         array similar to rules defined in cell2mat; 0 to 
%                         use a legacy parser; if set to a larger-than-1
%                         value, this option will specify the minimum
%                         dimension to enable the fast array parser. For
%                         example, if the input is a 3D array, setting
%                         FastArrayParser to 1 will return a 3D array;
%                         setting to 2 will return a cell array of 2D
%                         arrays; setting to 3 will return to a 2D cell
%                         array of 1D vectors; setting to 4 will return a
%                         3D cell array.
%           opt.ShowProgress [0|1]: if set to 1, loadjson displays a progress bar.
%
% output:
%      dat: a cell array, where {...} blocks are converted into cell arrays,
%           and [...] are converted to arrays
%
% examples:
%      dat=loadjson('{"obj":{"string":"value","array":[1,2,3]}}')
%      dat=loadjson(['examples' filesep 'example1.json'])
%      dat=loadjson(['examples' filesep 'example1.json'],'SimplifyCell',1)
%
% license:
%     BSD License, see LICENSE_BSD.txt files for details 
%
% -- this function is part of JSONLab toolbox (http://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
%

global JSONpos JSONinStr JSONlen JSONesc JSONindexesc JSONlenesc JSONisoct JSONarraytoken

if(regexp(fname,'^\s*(?:\[.+\])|(?:\{.+\})\s*$','once'))
   string=fname;
elseif(exist(fname,'file'))
   try
       string = fileread(fname);
   catch
       try
           string = urlread(['file://',fname]);
       catch
           string = urlread(['file://',fullfile(pwd,fname)]);
       end
   end
else
   error('input file does not exist');
end

JSONpos = 1; JSONlen = length(string); JSONinStr = string;
JSONisoct=exist('OCTAVE_VERSION','builtin');
JSONarraytoken=find(JSONinStr=='[' | JSONinStr==']' | JSONinStr=='"');
jstr=regexprep(JSONinStr,'\\\\','  ');
escquote=regexp(jstr,'\\"');
JSONarraytoken=sort([JSONarraytoken escquote]);

% String delimiters and escape chars identified to improve speed:
JSONesc = find(JSONinStr=='"' | JSONinStr=='\' ); % comparable to: regexp(JSONinStr, '["\\]');
JSONindexesc = 1; JSONlenesc = length(JSONesc);

opt=varargin2struct(varargin{:});

if(jsonopt('ShowProgress',0,opt)==1)
    opt.progressbar_=waitbar(0,'loading ...');
end
jsoncount=1;
while JSONpos <= JSONlen
    switch(next_char)
        case '{'
            data{jsoncount} = parse_object(opt);
        case '['
            data{jsoncount} = parse_array(opt);
        otherwise
            error_pos('Outer level structure must be an object or an array');
    end
    jsoncount=jsoncount+1;
end % while

jsoncount=length(data);
if(jsoncount==1 && iscell(data))
    data=data{1};
end

if(isfield(opt,'progressbar_'))
    close(opt.progressbar_);
end
end

%%-------------------------------------------------------------------------
function object = parse_object(varargin)
    parse_char('{');
    object = [];
    if next_char ~= '}'
        while 1
            str = parseStr(varargin{:});
            if isempty(str)
                error_pos('Name of value at position %d cannot be empty');
            end
            parse_char(':');
            val = parse_value(varargin{:});
            object.(valid_field(str))=val;
            if next_char == '}'
                break;
            end
            parse_char(',');
        end
    end
    parse_char('}');
    if(isstruct(object))
        object=struct2jdata(object);
    end
end

%%-------------------------------------------------------------------------

function object = parse_array(varargin) % JSON array is written in row-major order
global JSONpos JSONinStr JSONisoct
    parse_char('[');
    object = cell(0, 1);
    dim2=[];
    arraydepth=jsonopt('JSONLAB_ArrayDepth_',1,varargin{:});
    pbar=-1;
    if(isfield(varargin{1},'progressbar_'))
        pbar=varargin{1}.progressbar_;
    end

    if next_char ~= ']'
	if(jsonopt('FastArrayParser',1,varargin{:})>=1 && arraydepth>=jsonopt('FastArrayParser',1,varargin{:}))
            [endpos, e1l, e1r]=matching_bracket(JSONinStr,JSONpos);
            arraystr=['[' JSONinStr(JSONpos:endpos)];
            arraystr=regexprep(arraystr,'"_NaN_"','NaN');
            arraystr=regexprep(arraystr,'"([-+]*)_Inf_"','$1Inf');
            arraystr(arraystr==sprintf('\n'))=[];
            arraystr(arraystr==sprintf('\r'))=[];
            %arraystr=regexprep(arraystr,'\s*,',','); % this is slow,sometimes needed
            if(~isempty(e1l) && ~isempty(e1r)) % the array is in 2D or higher D
        	astr=JSONinStr((e1l+1):(e1r-1));
        	astr=regexprep(astr,'"_NaN_"','NaN');
        	astr=regexprep(astr,'"([-+]*)_Inf_"','$1Inf');
        	astr(astr==sprintf('\n'))=[];
        	astr(astr==sprintf('\r'))=[];
        	astr(astr==' ')='';
        	if(isempty(find(astr=='[', 1))) % array is 2D
                    dim2=length(sscanf(astr,'%f,',[1 inf]));
        	end
            else % array is 1D
        	astr=arraystr(2:end-1);
        	astr(astr==' ')='';
        	[obj, count, errmsg, nextidx]=sscanf(astr,'%f,',[1,inf]);
        	if(nextidx>=length(astr)-1)
                    object=obj;
                    JSONpos=endpos;
                    parse_char(']');
                    return;
        	end
            end
            if(~isempty(dim2))
        	astr=arraystr;
        	astr(astr=='[')='';
        	astr(astr==']')='';
        	astr(astr==' ')='';
        	[obj, count, errmsg, nextidx]=sscanf(astr,'%f,',inf);
        	if(nextidx>=length(astr)-1)
                    object=reshape(obj,dim2,numel(obj)/dim2)';
                    JSONpos=endpos;
                    parse_char(']');
                    if(pbar>0)
                        waitbar(JSONpos/length(JSONinStr),pbar,'loading ...');
                    end
                    return;
        	end
            end
            arraystr=regexprep(arraystr,'\]\s*,','];');
	else
            arraystr='[';
	end
        try
           if(JSONisoct && regexp(arraystr,'"','once'))
                error('Octave eval can produce empty cells for JSON-like input');
           end
           object=eval(arraystr);
           JSONpos=endpos;
        catch
         while 1
            newopt=varargin2struct(varargin{:},'JSONLAB_ArrayDepth_',arraydepth+1);
            val = parse_value(newopt);
            object{end+1} = val;
            if next_char == ']'
                break;
            end
            parse_char(',');
         end
        end
    end
    if(jsonopt('SimplifyCell',0,varargin{:})==1)
      try
        oldobj=object;
        object=cell2mat(object')';
        if(iscell(oldobj) && isstruct(object) && numel(object)>1 && jsonopt('SimplifyCellArray',1,varargin{:})==0)
            object=oldobj;
        elseif(size(object,1)>1 && ismatrix(object))
            object=object';
        end
      catch
      end
    end
    parse_char(']');
    
    if(pbar>0)
        waitbar(JSONpos/length(JSONinStr),pbar,'loading ...');
    end
end
%%-------------------------------------------------------------------------

function parse_char(c)
    global JSONpos JSONinStr JSONlen
    JSONpos=skip_whitespace(JSONpos,JSONinStr,JSONlen);
    if JSONpos > JSONlen || JSONinStr(JSONpos) ~= c
        error_pos(sprintf('Expected %c at position %%d', c));
    else
        JSONpos = JSONpos + 1;
        JSONpos=skip_whitespace(JSONpos,JSONinStr,JSONlen);
    end
end

%%-------------------------------------------------------------------------

function c = next_char
    global JSONpos JSONinStr JSONlen
    JSONpos=skip_whitespace(JSONpos,JSONinStr,JSONlen);
    if JSONpos > JSONlen
        c = [];
    else
        c = JSONinStr(JSONpos);
    end
end

%%-------------------------------------------------------------------------

function newpos=skip_whitespace(JSONpos,JSONinStr,JSONlen)
    newpos=JSONpos;
    while newpos <= JSONlen && isspace(JSONinStr(newpos))
        newpos = newpos + 1;
    end
end
    
%%-------------------------------------------------------------------------
function str = parseStr(varargin)
    global JSONpos JSONinStr JSONlen  JSONesc JSONindexesc JSONlenesc
 % JSONlen, ns = length(JSONinStr), keyboard
    if JSONinStr(JSONpos) ~= '"'
        error_pos('String starting with " expected at position %d');
    else
        JSONpos = JSONpos + 1;
    end
    str = '';
    while JSONpos <= JSONlen
        while JSONindexesc <= JSONlenesc && JSONesc(JSONindexesc) < JSONpos
            JSONindexesc = JSONindexesc + 1;
        end
        if JSONindexesc > JSONlenesc
            str = [str JSONinStr(JSONpos:JSONlen)];
            JSONpos = JSONlen + 1;
            break;
        else
            str = [str JSONinStr(JSONpos:JSONesc(JSONindexesc)-1)];
            JSONpos = JSONesc(JSONindexesc);
        end
        nstr = length(str);
        switch JSONinStr(JSONpos)
            case '"'
                JSONpos = JSONpos + 1;
                if(~isempty(str))
                    if(strcmp(str,'_Inf_'))
                        str=Inf;
                    elseif(strcmp(str,'-_Inf_'))
                        str=-Inf;
                    elseif(strcmp(str,'_NaN_'))
                        str=NaN;
                    end
                end
                return;
            case '\'
                if JSONpos+1 > JSONlen
                    error_pos('End of file reached right after escape character');
                end
                JSONpos = JSONpos + 1;
                switch JSONinStr(JSONpos)
                    case {'"' '\' '/'}
                        str(nstr+1) = JSONinStr(JSONpos);
                        JSONpos = JSONpos + 1;
                    case {'b' 'f' 'n' 'r' 't'}
                        str(nstr+1) = sprintf(['\' JSONinStr(JSONpos)]);
                        JSONpos = JSONpos + 1;
                    case 'u'
                        if JSONpos+4 > JSONlen
                            error_pos('End of file reached in escaped unicode character');
                        end
                        str(nstr+(1:6)) = JSONinStr(JSONpos-1:JSONpos+4);
                        JSONpos = JSONpos + 5;
                end
            otherwise % should never happen
                str(nstr+1) = JSONinStr(JSONpos);
                keyboard;
                JSONpos = JSONpos + 1;
        end
    end
    error_pos('End of file while expecting end of JSONinStr');
end

%%-------------------------------------------------------------------------

function num = parse_number(varargin)
    global JSONpos JSONinStr JSONisoct
    currstr=JSONinStr(JSONpos:min(JSONpos+30,end));
    if(JSONisoct~=0)
        numstr=regexp(currstr,'^\s*-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+\-]?\d+)?','end');
        [num] = sscanf(currstr, '%f', 1);
        delta=numstr+1;
    else
        [num, one, err, delta] = sscanf(currstr, '%f', 1);
        if ~isempty(err)
            error_pos('Error reading number at position %d');
        end
    end
    JSONpos = JSONpos + delta-1;
end

%%-------------------------------------------------------------------------

function val = parse_value(varargin)
    global JSONpos JSONinStr JSONlen
    
    if(isfield(varargin{1},'progressbar_'))
        waitbar(JSONpos/JSONlen,varargin{1}.progressbar_,'loading ...');
    end
    
    switch(JSONinStr(JSONpos))
        case '"'
            val = parseStr(varargin{:});
            return;
        case '['
            val = parse_array(varargin{:});
            return;
        case '{'
            val = parse_object(varargin{:});
            return;
        case {'-','0','1','2','3','4','5','6','7','8','9'}
            val = parse_number(varargin{:});
            return;
        case 't'
            if JSONpos+3 <= JSONlen && strcmpi(JSONinStr(JSONpos:JSONpos+3), 'true')
                val = true;
                JSONpos = JSONpos + 4;
                return;
            end
        case 'f'
            if JSONpos+4 <= JSONlen && strcmpi(JSONinStr(JSONpos:JSONpos+4), 'false')
                val = false;
                JSONpos = JSONpos + 5;
                return;
            end
        case 'n'
            if JSONpos+3 <= JSONlen && strcmpi(JSONinStr(JSONpos:JSONpos+3), 'null')
                val = [];
                JSONpos = JSONpos + 4;
                return;
            end
    end
    error_pos('Value expected at position %d');
end

%%-------------------------------------------------------------------------

function error_pos(msg)
    global JSONpos JSONinStr JSONlen
    poShow = max(min([JSONpos-15 JSONpos-1 JSONpos JSONpos+20],JSONlen),1);
    if poShow(3) == poShow(2)
        poShow(3:4) = poShow(2)+[0 -1];  % display nothing after
    end
    msg = [sprintf(msg, JSONpos) ': ' ...
    JSONinStr(poShow(1):poShow(2)) '<error>' JSONinStr(poShow(3):poShow(4)) ];
    error( ['JSONparser:invalidFormat: ' msg] );
end

%%-------------------------------------------------------------------------

function str = valid_field(str)
global JSONisoct
% From MATLAB doc: field names must begin with a letter, which may be
% followed by any combination of letters, digits, and underscores.
% Invalid characters will be converted to underscores, and the prefix
% "x0x[Hex code]_" will be added if the first character is not a letter.
    JSONpos=regexp(str,'^[^A-Za-z]','once');
    if(~isempty(JSONpos))
        if(~JSONisoct)
            str=regexprep(str,'^([^A-Za-z])','x0x${sprintf(''%X'',unicode2native($1))}_','once');
        else
            str=sprintf('x0x%X_%s',char(str(1)),str(2:end));
        end
    end
    if(isempty(regexp(str,'[^0-9A-Za-z_]', 'once' )))
        return;
    end
    if(~JSONisoct)
        str=regexprep(str,'([^0-9A-Za-z_])','_0x${sprintf(''%X'',unicode2native($1))}_');
    else
        JSONpos=regexp(str,'[^0-9A-Za-z_]');
        if(isempty(JSONpos))
            return;
        end
        str0=str;
        pos0=[0 JSONpos(:)' length(str)];
        str='';
        for i=1:length(JSONpos)
            str=[str str0(pos0(i)+1:JSONpos(i)-1) sprintf('_0x%X_',str0(JSONpos(i)))];
        end
        if(JSONpos(end)~=length(str))
            str=[str str0(pos0(end-1)+1:pos0(end))];
        end
    end
    %str(~isletter(str) & ~('0' <= str & str <= '9')) = '_';
end

%%-------------------------------------------------------------------------
function endpos = matching_quote(str,JSONpos)
JSONlen=length(str);
while(JSONpos<JSONlen)
    if(str(JSONpos)=='"')
        if(~(JSONpos>1 && str(JSONpos-1)=='\'))
            endpos=JSONpos;
            return;
        end        
    end
    JSONpos=JSONpos+1;
end
error('unmatched quotation mark');
end

%%-------------------------------------------------------------------------
function [endpos, e1l, e1r, maxlevel] = matching_bracket(str,JSONpos)
global JSONarraytoken
level=1;
maxlevel=level;
endpos=0;
bpos=JSONarraytoken(JSONarraytoken>=JSONpos);
tokens=str(bpos);
JSONlen=length(tokens);
JSONpos=1;
e1l=[];
e1r=[];
while(JSONpos<=JSONlen)
    c=tokens(JSONpos);
    if(c==']')
        level=level-1;
        if(isempty(e1r))
            e1r=bpos(JSONpos);
        end
        if(level==0)
            endpos=bpos(JSONpos);
            return
        end
    end
    if(c=='[')
        if(isempty(e1l))
            e1l=bpos(JSONpos);
        end
        level=level+1;
        maxlevel=max(maxlevel,level);
    end
    if(c=='"')
        JSONpos=matching_quote(tokens,JSONpos+1);
    end
    JSONpos=JSONpos+1;
end
if(endpos==0) 
    error('unmatched "]"');
end
end

function opt=varargin2struct(varargin)
%
% opt=varargin2struct('param1',value1,'param2',value2,...)
%   or
% opt=varargin2struct(...,optstruct,...)
%
% convert a series of input parameters into a structure
%
% authors:Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2012/12/22
%
% input:
%      'param', value: the input parameters should be pairs of a string and a value
%       optstruct: if a parameter is a struct, the fields will be merged to the output struct
%
% output:
%      opt: a struct where opt.param1=value1, opt.param2=value2 ...
%
% license:
%     BSD License, see LICENSE_BSD.txt files for details 
%
% -- this function is part of jsonlab toolbox (http://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
%

JSONlen=length(varargin);
opt=struct;
if(JSONlen==0) return; end
i=1;
while(i<=JSONlen)
    if(isstruct(varargin{i}))
        opt=mergestruct(opt,varargin{i});
    elseif(ischar(varargin{i}) && i<JSONlen)
        opt=setfield(opt,lower(varargin{i}),varargin{i+1});
        i=i+1;
    else
        error('input must be in the form of ...,''name'',value,... pairs or structs');
    end
    i=i+1;
end
end

function val=jsonopt(key,default,varargin)
%
% val=jsonopt(key,default,optstruct)
%
% setting options based on a struct. The struct can be produced
% by varargin2struct from a list of 'param','value' pairs
%
% authors:Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% $Id: loadjson.m 371 2012-06-20 12:43:06Z fangq $
%
% input:
%      key: a string with which one look up a value from a struct
%      default: if the key does not exist, return default
%      optstruct: a struct where each sub-field is a key 
%
% output:
%      val: if key exists, val=optstruct.key; otherwise val=default
%
% license:
%     BSD License, see LICENSE_BSD.txt files for details
%
% -- this function is part of jsonlab toolbox (http://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
% 

val=default;
if(nargin<=2) return; end
opt=varargin{1};
if(isstruct(opt))
    if(isfield(opt,key))
       val=getfield(opt,key);
    elseif(isfield(opt,lower(key)))
       val=getfield(opt,lower(key));
    end
end
end

function newdata=struct2jdata(data,varargin)
%
% newdata=struct2jdata(data,opt,...)
%
% convert a JData object (in the form of a struct array) into an array
%
% authors:Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% input:
%      data: a struct array. If data contains JData keywords in the first
%            level children, these fields are parsed and regrouped into a
%            data object (arrays, trees, graphs etc) based on JData 
%            specification. The JData keywords are
%               "_ArrayType_", "_ArraySize_", "_ArrayData_"
%               "_ArrayIsSparse_", "_ArrayIsComplex_"
%      opt: (optional) a list of 'Param',value pairs for additional options 
%           The supported options include
%               'Recursive', if set to 1, will apply the conversion to 
%                            every child; 0 to disable
%
% output:
%      newdata: the covnerted data if the input data does contain a JData 
%               structure; otherwise, the same as the input.
%
% examples:
%      obj=struct('_ArrayType_','double','_ArraySize_',[2 3],
%                 '_ArrayIsSparse_',1 ,'_ArrayData_',null);
%      ubjdata=struct2jdata(obj);
%
% license:
%     BSD License, see LICENSE_BSD.txt files for details 
%
% -- this function is part of JSONLab toolbox (http://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
%

fn=fieldnames(data);
newdata=data;
JSONlen=length(data);
if(jsonopt('Recursive',0,varargin{:})==1)
  for i=1:length(fn) % depth-first
    for j=1:JSONlen
        if(isstruct(getfield(data(j),fn{i})))
            newdata(j)=setfield(newdata(j),fn{i},jstruct2array(getfield(data(j),fn{i})));
        end
    end
  end
end
if(~isempty(strmatch('x0x5F_ArrayType_',fn)) && ~isempty(strmatch('x0x5F_ArrayData_',fn)))
  newdata=cell(JSONlen,1);
  for j=1:JSONlen
    ndata=cast(data(j).x0x5F_ArrayData_,data(j).x0x5F_ArrayType_);
    iscpx=0;
    if(~isempty(strmatch('x0x5F_ArrayIsComplex_',fn)))
        if(data(j).x0x5F_ArrayIsComplex_)
           iscpx=1;
        end
    end
    if(~isempty(strmatch('x0x5F_ArrayIsSparse_',fn)))
        if(data(j).x0x5F_ArrayIsSparse_)
            if(~isempty(strmatch('x0x5F_ArraySize_',fn)))
                dim=double(data(j).x0x5F_ArraySize_);
                if(iscpx && size(ndata,2)==4-any(dim==1))
                    ndata(:,end-1)=complex(ndata(:,end-1),ndata(:,end));
                end
                if isempty(ndata)
                    % All-zeros sparse
                    ndata=sparse(dim(1),prod(dim(2:end)));
                elseif dim(1)==1
                    % Sparse row vector
                    ndata=sparse(1,ndata(:,1),ndata(:,2),dim(1),prod(dim(2:end)));
                elseif dim(2)==1
                    % Sparse column vector
                    ndata=sparse(ndata(:,1),1,ndata(:,2),dim(1),prod(dim(2:end)));
                else
                    % Generic sparse array.
                    ndata=sparse(ndata(:,1),ndata(:,2),ndata(:,3),dim(1),prod(dim(2:end)));
                end
            else
                if(iscpx && size(ndata,2)==4)
                    ndata(:,3)=complex(ndata(:,3),ndata(:,4));
                end
                ndata=sparse(ndata(:,1),ndata(:,2),ndata(:,3));
            end
        end
    elseif(~isempty(strmatch('x0x5F_ArraySize_',fn)))
        if(iscpx && size(ndata,2)==2)
             ndata=complex(ndata(:,1),ndata(:,2));
        end
        ndata=reshape(ndata(:),data(j).x0x5F_ArraySize_);
    end
    newdata{j}=ndata;
  end
  if(JSONlen==1)
      newdata=newdata{1};
  end
end
end

function s=mergestruct(s1,s2)
%
% s=mergestruct(s1,s2)
%
% merge two struct objects into one
%
% authors:Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2012/12/22
%
% input:
%      s1,s2: a struct object, s1 and s2 can not be arrays
%
% output:
%      s: the merged struct object. fields in s1 and s2 will be combined in s.
%
% license:
%     BSD License, see LICENSE_BSD.txt files for details 
%
% -- this function is part of jsonlab toolbox (http://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
%

if(~isstruct(s1) || ~isstruct(s2))
    error('input parameters contain non-struct');
end
if(length(s1)>1 || length(s2)>1)
    error('can not merge struct arrays');
end
fn=fieldnames(s2);
s=s1;
for i=1:length(fn)              
    s=setfield(s,fn{i},getfield(s2,fn{i}));
end
end
