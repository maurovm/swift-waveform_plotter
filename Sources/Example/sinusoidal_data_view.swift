/**
 * \file    sinusoidal_data_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 14, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public struct Sinusoidal_data_view: View
{
    
    public var body: some View
    {
        
        VStack(spacing: 0)
        {
            HStack
            {   Spacer()
                
                Button("Start streaming", action: start)
                    .buttonStyle(.borderedProminent)
            }
            Waveform_signal_view(
                    data        : model.values,
                    write_index : model.next_write_index,
                    y_min       : model.values_min,
                    y_max       : model.values_max,
                    x_min       : model.t_min,
                    x_max       : model.t_max,
                    signal_name : "Sinusoidal waveform"
                )
        }
        .padding(.horizontal)
        .padding(.vertical, 30)
        
    }
    
    
    public init(
            display_seconds    : Int = 1,
            signal_seconds     : Int = 60
        )
    {
        
        self._model = StateObject<Sinusoidal_data_model>(
                wrappedValue: Sinusoidal_data_model(
                        buffer_seconds: display_seconds,
                        signal_seconds: signal_seconds
                    )
            )
        
    }
    
    
    // MARK: Actions
    
    
    private func start()
    {
        
        model.start()
        
    }
    
    
    // MARK: - Private state
    
    @StateObject private var model  : Sinusoidal_data_model
    
}


struct Sinusoidal_data_view_Previews: PreviewProvider
{
    
    static var previews: some View
    {
        Sinusoidal_data_view(
                display_seconds : 1,
                signal_seconds  : 3
            )
            .previewInterfaceOrientation(.landscapeRight)
    }
}
