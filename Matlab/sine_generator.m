%%
% Generates a 16-bit sinusoidal with baseline wander and added noise
%
%

%% Signal properties

signal_resolution = 16;
signal_amplitude  = floor( (2^signal_resolution - 1) / 2 );
signal_fs         = 3;

baseline_resolution = 16;
baseline_amplitude  = floor( (2^baseline_resolution - 1) / 2 );
baseline_fs         = 1/10;

noise_amplitude    = (2^12 - 1);

% Generate time vector

number_of_seconds = 10;
sampling_fs       = 75;

number_of_samples = number_of_seconds * sampling_fs;

x = (0 : number_of_samples-1) / sampling_fs;

% Generate signal values
y_double = signal_amplitude * sin( signal_fs * 2 * pi * x );

y_baseline = baseline_amplitude * sin( baseline_fs * 2* pi * x );

y_noise    = noise_amplitude * normrnd(0,1, [1, number_of_samples]);

y = floor( y_double + y_baseline + y_noise);

a = min(y);
b = max(y);

c = -signal_amplitude + 1;
d = signal_amplitude - 1;
clip_values_flag  = true;
plot_summary_flag = false;


y_scaled = change_number_range( ...
            y           , ...
            a                 , ...
            b                 , ...
            c                 , ...
            d                 , ...
            clip_values_flag  , ...
            plot_summary_flag   ...
            );




% y_min = -(signal_amplitude * 1.2);
% y_max = +(signal_amplitude * 1.2);
% plot(x, y_noise)
plot(x, y_scaled)
% set(gca, 'YLim', [ y_min  y_max ])
