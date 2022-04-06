% File    : change_number_range.m   
% Author  : Mauricio Villarroel
% Created : Jan 2, 2015
% ____________________________________________________________________________
%
% Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
%
% SPDX-License-Identifer:  GPL-2.0-only
% ________________________________________________________________________
%
% DESCRIPTON
% ----------
%
%   Change the range of values in a time series from [a,b] to [c,d]
% using the formula:
%
%            (d-c)   
% data_out = ----- * (data_in - a)  +  c
%            (b-a)
%
% INPUT
% -----
%
%   data_in  : N-channels, column-based input time series
%
%   [a,b]    : Original min/max value range
%
%   [c,d]    : New min/max value range.
%
%   clip_values_flag  : Clip data_in to the [a,b] range prior re-scaling
%              Default: true
%
% OUTPUT
% -----
%
%   data_out : Scaled output time series
%
% ________________________________________________________________________


function [ data_out ] = change_number_range( ...
            data_in           , ...
            a                 , ...
            b                 , ...
            c                 , ...
            d                 , ...
            clip_values_flag  , ...
            plot_summary_flag   ...
         )

narginchk(1, inf);

%% Process function parameters with default values
%

if nargin < 2
    a = min(data_in(:));
end
if nargin < 3
    b = max(data_in(:));
end
if nargin < 4
    c = 0;
end
if nargin < 5
    d = 1;
end
if nargin < 6
    clip_values_flag = true;
end
if nargin < 7
    plot_summary_flag = false;
end

%% Re-scale values
%

old_range    = b - a;
new_range    = d - c;
range_factor = new_range / old_range; 

data_out = ( range_factor * (data_in - a) ) + c;

if clip_values_flag
    data_out( data_out < c ) = c;
    data_out( data_out > d ) = d;
end

%% Summary plot

if plot_summary_flag
    
    
    x = 1:length(data_in);
    
    figure;
    
    ts_axh(1) = subplot(2, 4, 1:3);
    
    plot( x, data_in );
    title('Input data');
    
    hist_axh(1) = subplot(2, 4, 4);
    
    histogram(data_in);
    title('Histogram');
    
    ts_axh(2) = subplot(2, 4, 5:7 );
    
    plot( x, data_out );
    title('Scaled data');
    
    hist_axh(2) = subplot(2, 4, 8);
    
    histogram(data_out);
    title('Histogram');
    
    xlabel( 'Sample number' );
    
    linkaxes(ts_axh,  'x');
    %linkaxes(hist_axh,  'x');
    
end

end
