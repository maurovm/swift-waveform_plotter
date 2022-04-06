/**
 * \file    sinusoidal_data_model.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 13, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI
import Combine


@MainActor
public class Sinusoidal_data_model : ObservableObject
{
    
    @Published public private(set) var values     : [Int] = []
    
    /**
     * The offset in the data vector to extract data
     */
    @Published public private(set)  var next_write_index : Int = 0
    
    
    @Published public private(set) var values_min : Int   = -1
    @Published public private(set) var values_max : Int   = 1
    @Published public private(set) var t_min      : Int   = 0
    @Published public private(set) var t_max      : Int   = 1
    
    
    public init(
            buffer_seconds     : Int   = 1,
            signal_seconds     : Int   = 60,
            signal_frequency   : Float = 3,
            baseline_frequency : Float = 1.0/10.0,
            noise_resolution   : Int   = 12,
            sampling_fs        : Int   = 75,
            read_length        : Int   = 25
        )
    {
        
        data = Sinusoidal_data_generator(
            seconds           : signal_seconds,
            signal_frequency  : signal_frequency,
            baseline_frequency: baseline_frequency,
            noise_resolution  : noise_resolution,
            sampling_fs       : sampling_fs,
            read_length       : read_length
            )
        
        
        read_interval = Double(read_length) / Double(sampling_fs)
        
        initialise_data(buffer_seconds)
        
    }
 
    
    deinit
    {
        data_reader_timer?.cancel()
    }
    

    public func start()
    {
        
        data_reader_timer = Timer.publish(
                    every : read_interval,
                    on    : .main,
                    in    : .common
                )
            .autoconnect()
            .sink
            {
                [weak self] _ in
                self?.read_next_data_frame()
            }
        
    }
    
    
    // MARK: - Private state
    
    
    private let data : Sinusoidal_data_generator
    
    
    // MARK: - Private interface
    
    
    private let read_interval : TimeInterval
    
    /**
     * The timer task to read data from sine wave generator
     */
    private var data_reader_timer : AnyCancellable?
    
    
    private func initialise_data( _  buffer_seconds : Int )
    {
        
        Task
        {
            [weak self] in
        
            
            // Preallocate the data array
            
            if let sampling_frequency = await self?.data.signal_sampling_freq
            {
                let number_of_samples  = buffer_seconds * sampling_frequency
                self?.values = [Int](repeating: 0, count: number_of_samples)
                self?.t_max  = buffer_seconds
            }

            // Initialiser the generator
            
            await self?.data.generate_intial_data()
            await self?.read_data()
        }
        
    }
    
    private func read_next_data_frame()
    {
        
        Task
        {
            [weak self] in
            await self?.read_data()
        }
        
    }
    
    
    private func read_data() async
    {
        
        let new_values = await data.read_data()
        
        if next_write_index >= values.count
        {
            next_write_index = 0
        }
        
        if (next_write_index + new_values.count) <= values.count
        {
            for i in 0..<new_values.count
            {
                values[next_write_index + i] = new_values[i]
            }
            next_write_index += new_values.count
        }
        else
        {
            let limit = values.count - next_write_index
            
            for i in 0..<limit
            {
                values[next_write_index + i] = new_values[i]
            }
            next_write_index = 0
            
            for i in limit..<new_values.count
            {
                values[next_write_index + i] = new_values[i]
            }
            next_write_index += (new_values.count - limit)
        }
        
        if let y_min = values.min() ,
           let y_max = values.max()
        {
            values_min = y_min
            values_max = y_max
        }
        
    }
    
}
