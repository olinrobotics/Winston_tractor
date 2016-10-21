function JD = find_Julian(year,month,day,hour,minute,second) 
% starting March 1, 4801 BC 

a = floor((14 - month)/12);
y = year + 4800 - a;
m = month + 12*a - 3;
% if starting from a Gregorian calendar date
% Note: (153m+2)/5 gives the number of days since March 1
JDN = day + floor((153*m + 2)/5) + 365*y + floor(y/4) - floor(y/100) + floor(y/400) - 32045;

JD = JDN + (hour - 12)/24 + minute/1440 + second/86400;
