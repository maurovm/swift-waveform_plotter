/**
 * \file    signal_shape.swift
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
import Accelerate


struct Signal_shape : Shape
{
    
    public init(
            data        : [Int],
            y_min       : CGFloat,
            y_max       : CGFloat
        )
    {
        
        self.values      = data
        self.y_min       = y_min
        self.y_max       = y_max
        
    }
    
    
    func path(in rect: CGRect) -> Path
    {
        
        if values.count < 1
        {
            return Path{ _ in}
        }

        var points = [CGPoint](repeating: CGPoint(x: rect.width, y: rect.midY), count: values.count)

        var index = 0;

        for x in 0..<values.count
        {
            let y = CGFloat(values[x])

            let screen_x = CGFloat(x) * rect.width / CGFloat(values.count)
            let screen_y = change_number_range(
                    data_in: y, a: y_min, b: y_max, c: rect.height, d: 0
                )

            points[index].x = screen_x
            points[index].y = screen_y
            index += 1
        }
        
        return Path
        {
            p in
            p.move(to: CGPoint(x: 0, y: rect.midY))
            p.addLines(points)
        }
        
    }

    
    // MARK: - Private state
    
    
    private let values : [Int]
    private let y_min  : CGFloat
    private let y_max  : CGFloat
    
    
    // MARK: - Private interface
    
    
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
            data_in : CGFloat,
            a       : CGFloat,
            b       : CGFloat,
            c       : CGFloat,
            d       : CGFloat
        ) -> CGFloat
    {
        
        let old_range    = b - a
        let new_range    = d - c
        let range_factor = new_range / old_range

        return ( range_factor * (data_in - a) ) + c
        
    }
    
}
