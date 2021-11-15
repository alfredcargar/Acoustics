%compute the distance between point A(x,y) and point B(x,y)
function [d] = dpoints(A,B)
  d = sqrt((A(1)-B(1))^2+(A(2)-B(2))^2);
  return;
endfunction
