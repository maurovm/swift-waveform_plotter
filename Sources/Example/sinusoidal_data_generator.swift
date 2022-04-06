/**
 * \file    sinusoidal_data_generator.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 13, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import Accelerate


/**
 * Generates a 16-bit integer sinusoid, of a given `frequency`,
 * length `seconds` and sampled at `sampling_fs`
 *
 * Make sure you call the method `generate_intial_data` before using this
 * class
 */
actor Sinusoidal_data_generator
{
    
    public var signal_sampling_freq : Int
    {
        sampling_fs
    }
    
    
    public init(
            seconds            : Int   = 60,
            signal_frequency   : Float = 3,
            baseline_frequency : Float = 1.0/10.0,
            noise_resolution   : Int   = 12,
            sampling_fs        : Int   = 75,
            read_length        : Int   = 75
        )
    {
        
        self.seconds            = seconds
        self.signal_frequency   = signal_frequency
        self.baseline_frequency = baseline_frequency
        self.noise_resolution   = noise_resolution
        self.sampling_fs        = sampling_fs
        self.read_length        = read_length
        
        total_number_of_samples = self.seconds * self.sampling_fs
        
    }
    
    
    /**
     * This methods was included as a separate implementation, as it cannot
     * be added to the init. XCode complains with a warning:
     *
     * "This use of actor 'self' can only appear in an async initializer"
     */
    public func generate_intial_data()
    {
        
        initialise_time_vector()
        initialise_data_values()
        
    }
    
    
    /**
     * Classes call this method to generate new data
     */
    public func read_data() -> [Int]
    {
        
        if y.count < read_length
        {
            return []
        }
        
        if x_offset > (total_number_of_samples - read_length)
        {
            x_offset = 0
        }
        
        var new_values = [Int](repeating: 0, count: read_length)
        let start_index = x_offset
        
        for i in start_index..<(start_index + read_length)
        {
            new_values[i - start_index] = y[i]
        }

        x_offset += read_length
        
        return new_values
        
    }
    
    
    // MARK: - Private state
    
    
    // Signal properties
    
    /**
     * Power of 2's to generate the range of numbers for the data
     */
    private let base : Int = 2
    
    private let signal_resolution  : Int   = 16  // 16 bits
    private let signal_frequency   : Float
    private let baseline_frequency : Float
    
    private let noise_resolution   : Int // 12 bits
    
    // Data generated properties

    private let seconds     : Int
    private let sampling_fs : Int
    private let total_number_of_samples : Int
    
    private var t : [Float] = []  // time vector
    private var y : [Int]   = []  // signal values
    
    
    /**
     * Every time we read data, we will read this amount of data samples
     */
    private let read_length : Int
    
    /**
     * The offset in the data vector to extract data
     */
    private var x_offset : Int = 0
    
    
    // MARK: - Private interface
    
    
    private func initialise_time_vector()
    {
        
        // x = [0 1 2 3 ...]
        let x = vDSP.ramp(withInitialValue: Float(0.0),
                          increment: Float(1),
                          count: total_number_of_samples)
        
        // t = x ./ sampling_fs
        t = vDSP.divide(x, Float(sampling_fs))
        
    }
    
    
    private func initialise_data_values()
    {
        
        
        var y_signal   = generate_sine_wave(frequency: signal_frequency)
        let y_baseline = generate_sine_wave(frequency: baseline_frequency)
        
        // Compute the amplitude
        
        let noise_range     = pow(Float(base), Float(noise_resolution)) - 1
        let noise_amplitude = floor(noise_range / 2)
        
        // Generate the data as a sum of the two previoys sine wave + added
        // random noise
        
        for i in 0..<total_number_of_samples
        {
            let noise_value = noise_amplitude * Float.random(in: 0...1)
            y_signal[i] = y_signal[i] + y_baseline[i] + noise_value
        }
        
        // Compute the final 16-bit integer signal
        
        guard let y_min = y_signal.min() ,
              let y_max = y_signal.max()
            else
            {
                assertionFailure("Can't compute the min/max of the signal generated")
                return
            }
        
        let range = pow(Float(base), Float(signal_resolution)) - 1
        let max_amplitude = floor(range / 2) - 1
        let min_amplitude = -max_amplitude
        
        y = [Int](repeating: 0, count: total_number_of_samples)
        
        for i in 0..<total_number_of_samples
        {
            let value_scaled = change_number_range(
                    data_in: y_signal[i],
                    a: y_min,
                    b: y_max,
                    c: min_amplitude,
                    d: max_amplitude
                )
            y[i] = Int( floor(value_scaled) )
        }
        
    }
    
    
    private func generate_sine_wave(
            frequency : Float
        ) -> [Float]
    {
        
        // Compute the amplitude
        
        let range = pow(Float(base), Float(signal_resolution)) - 1
        let amplitude = floor(range / 2)
        
        // Generate the sine wave
        
        var signal = [Float](repeating: 0, count: total_number_of_samples)
        
        for i in 0..<total_number_of_samples
        {
            signal[i] = amplitude * sin( frequency * 2 * .pi * t[i] )
        }
        return signal
        
    }
    
    
    /**
     *   Change the range of a value in a time series from [a,b] to [c,d]
     * using the formula:
     *
     *            (d-c)
     * data_out = ----- * (data_in - a)  +  c
     *            (b-a)
     *
     * INPUT
     * -----
     *
     *   data_in  : Input value
     *
     *   [a,b]    : Original min/max value range
     *
     *   [c,d]    : New min/max value range.
     *
     *   clip_values_flag  : Clip data_in to the [a,b] range prior re-scaling
     *              Default: true
     *
     * OUTPUT
     * -----
     *
     *   data_out : Scaled output value
     *
     */
    private func change_number_range(
            data_in : Float,
            a       : Float,
            b       : Float,
            c       : Float,
            d       : Float
        ) -> Float
    {
        
        let old_range    = b - a
        let new_range    = d - c
        let range_factor = new_range / old_range

        return ( range_factor * (data_in - a) ) + c
        
    }
}
