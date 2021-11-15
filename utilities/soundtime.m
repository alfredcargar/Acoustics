%computes the time in seconds the sound takes to travel from A(x1,y1) to
%B(x2,y2) in a room with temperature T(celsius)

function [t] = soundtime(A,B,T)
  C = 331.4 + 0.6*T;
  d = dpoints(A,B);
  t = d/C;
  return;
endfunction