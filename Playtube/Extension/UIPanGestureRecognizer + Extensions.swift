//
//  UIPanGestureRecognizer + Extensions.swift
//  Playtube
//
//  Created by iMac on 24/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import UIKit

extension UIPanGestureRecognizer {

    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        static let up = PanGestureDirection(rawValue: 1 << 0)
        static let down = PanGestureDirection(rawValue: 1 << 1)
        static let left = PanGestureDirection(rawValue: 1 << 2)
        static let right = PanGestureDirection(rawValue: 1 << 3)
    }

    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let isVerticalGesture = abs(velocity.y) > abs(velocity.x)
        if isVerticalGesture {
            return velocity.y > 0 ? .down : .up
        } else {
            return velocity.x > 0 ? .right : .left
        }
    }
}
