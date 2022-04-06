/**
 * \file    written_index_shape.swift
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
import Accelerate


struct Written_index_shape : Shape
{
    
    public init(
            data_length : Int,
            write_index : Int
        )
    {
        
        self.data_length = data_length
        self.write_index = write_index
        
    }
    
    
    func path(in rect: CGRect) -> Path
    {
        
        if data_length < 1
        {
            return Path{ _ in}
        }
        
        let write_offset = CGFloat(write_index) * rect.width / CGFloat(data_length)
        let start_point  = CGPoint(x: write_offset, y: rect.minY + 4)
        let end_point    = CGPoint(x: write_offset, y: rect.maxY - 4)
        
        
        return Path
        {
            p in
            p.move(to: start_point)
            p.addLine(to: end_point)
        }
        
    }

    
    // MARK: - Private state
    
    
    private let data_length : Int
    private let write_index : Int
    
}
