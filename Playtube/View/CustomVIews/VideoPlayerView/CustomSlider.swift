//
//  CustomSlider.swift
//  Playtube
//
//  Created by iMac on 21/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 3

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: bounds.origin.x, y: bounds.origin.y + trackHeight), size: CGSize(width: bounds.width, height: trackHeight))
    }

    private var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
}
