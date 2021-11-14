function [samples] = mstosmp(ms,fs)
  samples = round((ms/(1/fs))/1000);
  return;
endfunction
