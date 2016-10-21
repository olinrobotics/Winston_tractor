function [xx,yy,xxx,yyy] = findClosestPointOnLine(lookAhead,x,y)
A = x(3) - x(1);
B = y(3) - y(1);
C = x(2) - x(1);
D = y(2) - y(1);

dot = A*C + B*D;
len_sq = C*C + D*D;
param = dot/len_sq;
if(param<0 || (x(1)==x(2) && y(1)==y(2)))
    xx = x(1);
    yy = y(1);
else
    if(param>1)
        xx=x(2);
        yy=y(2);
    else
        xx= x(1)+param*C;
        yy= y(1)+param*D;
    end
end
xxx = lookAhead/sqrt(len_sq)*C + xx;
yyy = lookAhead/sqrt(len_sq)*D + yy;

end