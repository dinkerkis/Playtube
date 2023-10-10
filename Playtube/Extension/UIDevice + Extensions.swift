//
//  UIDevice + Extensions.swift
//  Playtube
//
//  Created by iMac on 09/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
}
