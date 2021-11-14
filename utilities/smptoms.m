% converts samples to milliseconds

function [ms] = smptoms(samples,fs)
  ms = (samples / fs) * 1e3;
  return;
endfunction
