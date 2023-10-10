//
//  TabBar.swift
//  Playtube
//
//  Created by Abdul Moid on 17/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class TabBar: UITabBar {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = 0
        layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        layer.borderWidth = 0.2
    }
}
