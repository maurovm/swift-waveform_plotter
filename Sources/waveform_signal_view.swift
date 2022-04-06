/**
 * \file    waveform_signal_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 2, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public struct Waveform_signal_view : View
{
    
    public var body: some View
    {
        
        ZStack(alignment: .center)
        {
            Background_panel
            
            VStack(alignment: .center, spacing: 0)
            {
                Header_view
                    .frame(height: tools_panel_size)
                
                HStack(spacing: 0)
                {
                    Y_axis_view
                        .frame(width: y_axis_panel_width)
                    
                    ZStack
                    {
                        Rectangle()
                            .fill(.white)
                            .shadow(
                                color:  .gray,
                                radius: 5,
                                x:      5,
                                y:      5
                            )
                        
                        
                        Signal_shape(
                                data        : values,
                                y_min       : y_min,
                                y_max       : y_max
                            )
                            .stroke(lineWidth: 1.0)
                            .border(.black)
                        
                        
                        Written_index_shape(
                                data_length : values.count,
                                write_index : write_index
                            )
                            .stroke(
                                .gray,
                                style: StrokeStyle(
                                    lineWidth: 5,
                                    lineCap  : .round,
                                    lineJoin : .round
                                )
                            )
                    }
                    .padding(.trailing, 10)
                }
                
                Footer_view
                    .frame(height: x_axis_panel_height)
            }
        }
        
    }

    
    /**
     * Class initialiser
     */
    public init(
            data        : [Int],
            write_index : Int,
            y_min       : Int,
            y_max       : Int,
            x_min       : Int,
            x_max       : Int,
            signal_name : String = "Signal name"
        )
    {
        
        self.values      = data
        self.write_index = write_index
        self.y_min       = CGFloat(y_min)
        self.y_max       = CGFloat(y_max)
        self.x_min       = CGFloat(x_min)
        self.x_max       = CGFloat(x_max)
        self.signal_name = signal_name
        
    }
    
    
    // MARK: - Private views
    
    
    private var Background_panel : some View
    {
        Color.cyan
            .cornerRadius(10)
            .shadow(
                color:  .gray,
                radius: 5,
                x:      10,
                y:      10
            )
            .opacity(0.4)
    }
    
    
    private var Header_view : some View
    {
        HStack(alignment: .center)
        {
            Rectangle()
                .opacity(0)
                .frame(width: y_axis_panel_width)
            
            Tools_view
        }
    }
    
    
    private var Tools_view : some View
    {
        HStack(alignment: .center)
        {
            Spacer()
            
            Spacer()
        }
    }
    
    
    private var Y_axis_view : some View
    {
        VStack
        {
            Text(y_max_formatted)
                .font(tick_font)
                .frame(alignment: .trailing)
            
            Spacer()
            
            Text(signal_name)
                .font(axis_font)
                .rotationEffect(Angle(degrees: -90))
                .fixedSize()
                .frame(width: y_axis_panel_width)
            
            Spacer()
            
        
            Text(y_min_formatted)
                .font(tick_font)
                .frame(alignment: .trailing)
        }
    }
    
    
    private var Footer_view : some View
    {
        HStack(alignment: .center)
        {
            Rectangle()
                .opacity(0)
                .frame(width: y_axis_panel_width)
            
            X_axis_view
                .frame(height: x_axis_panel_height)
        }
    }
    
    
    private var X_axis_view : some View
    {
        HStack(alignment: .center)
        {
            Text(x_min_formatted)
                .font(tick_font)
                .frame(alignment: .leading)
            
            Spacer()
            
            Text("Time (seconds)")
                .font(axis_font)
                .frame(height: x_axis_panel_height)
            
            Spacer()
            
        
            Text(x_max_formatted)
                .font(tick_font)
                .padding(.trailing)
                .frame(alignment: .trailing)
        }
    }
    
    
    // MARK: - Private state
    
    
    private let values : [Int]
    
    private let write_index : Int
    
    private let y_min  : CGFloat
    private let y_max  : CGFloat
    private let x_min  : CGFloat
    private let x_max  : CGFloat
    
    private let signal_name : String
    
    private let x_axis_panel_height : CGFloat = 40
    private let y_axis_panel_width  : CGFloat = 40
    private let tools_panel_size    : CGFloat = 20
    
    private let axis_font  : Font = .custom("Helvetica", size: 14).bold()
    private let tick_font  : Font = .custom("Helvetica", size: 12)
    
    
    private var y_min_formatted : String
    {
        let scaled = Int( round( floor(y_min) ) )
        return "\(scaled)"
    }
    
    private var y_max_formatted : String
    {
        let scaled = Int( round( floor(y_max) ) )
        return "\(scaled)"
    }
    
    private var x_min_formatted : String
    {
        return "\(x_min)"
    }
    
    private var x_max_formatted : String
    {
        return "\(x_max)"
    }
    
}



struct Waveform_signal_view_Previews: PreviewProvider
{
    
    @StateObject static var model = Sinusoidal_data_model(
            buffer_seconds : 1,
            signal_seconds : 5
        )
    
    
    static var previews: some View
    {
        Waveform_signal_view(
                data        : model.values,
                write_index : model.next_write_index,
                y_min       : model.values_min,
                y_max       : model.values_max,
                x_min       : model.t_min,
                x_max       : model.t_max
            )
        .previewInterfaceOrientation(.landscapeRight)
    }
    
}



