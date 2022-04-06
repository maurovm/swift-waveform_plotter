len = length(blespecnoninPPG);
fs = 75;

t = (0:len-1) / fs;

figure;
plot(t/60, blespecnoninPPG);