% converts milliseconds to samples

function [samples] = mstosmp(ms,fs)
  samples = round((ms/( 1/fs )) / 1e3);
  return;
endfunction
