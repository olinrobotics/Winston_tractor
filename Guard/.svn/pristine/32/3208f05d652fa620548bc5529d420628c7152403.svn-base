function str = pbToText(pb)
str = pb.build.toString().toCharArray()'; % native display function
str = strtrim(str); % remove leading and trailing whitespace
str = strrep(str, sprintf('\n'), ';'); % replace newline with semicolon
str = strrep(str, ' ', ''); % remove all remaining whitespace
end
