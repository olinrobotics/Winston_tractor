function [yi, mi, mmi] = hermite(xa, ya, ma, xb, yb, mb, xi)
if(nargin==0)
  xi = -3:0.1:7;
  [yi, mi, mmi] = hermite(-3, 3, -1, 7, 5, 5, xi);
  figure;
  plot(xi, yi, '-o');
  axis('equal');
  hold('on');
  plot(xi, mi, '-o');
  axis('equal');
  plot(xi, mmi, '-o');
  axis('equal');
  return;
end
dx = xb-xa;
if(abs(dx)<eps)
  yi = (ya+yb)/2;
  mi = (ma+mb)/2;
else
  t = (xi-xa)/dx;
  s = (xb-xi)/dx;
  t2 = t.*t;
  t3 = t.*t2;
  h00 = 2*t3-3*t2+1;
  h10 = t3-2*t2+t;
  h01 = 3*t2-2*t3;
  h11 = t3-t2;
  yi = h00*ya+h10*dx*ma+h01*yb+h11*dx*mb;
  mi = (ma*s.*(2*xa+xb-3*xi))/dx-(mb*t.*(xa+2*xb-3*xi))/dx-(6*ya*t.*s)/dx+(6*yb*t.*s)/dx; %diff(yi, 'xi');
  if(nargout>=3)
    dx2 = dx*dx;
    mmi = yb*(6-12*t)/dx2-ya*(6-12*t)/dx2-ma*(4-6*t)/dx-mb*(2-6*t)/dx;
  end
end
end
