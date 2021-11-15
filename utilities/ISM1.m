%Image Source Method
%Computes the virtual sources of the 1st reflections off the walls.

%Output: matrix storing 4 pairs fo coordinates, one for each wall.

function [output] = ISM1(S,D)

dx1 = S(1);
dx2 = D(1)-S(1);
dy1 = S(2);
dy2 = D(2)-S(2);

root = struct('xpos',S(1),'ypos',S(2));

root.right = struct('xpos',root.xpos+2*dx2,'ypos',root.ypos);
root.left = struct('xpos',root.xpos-2*dx1,'ypos',root.ypos);
root.up = struct('xpos',root.xpos,'ypos',root.ypos+2*dy2);
root.down = struct('xpos',root.xpos,'ypos',root.ypos-2*dy1);

output = [root.up.xpos,root.up.ypos;
          root.down.xpos,root.down.ypos;
          root.left.xpos,root.left.ypos;
          root.right.xpos,root.right.ypos];