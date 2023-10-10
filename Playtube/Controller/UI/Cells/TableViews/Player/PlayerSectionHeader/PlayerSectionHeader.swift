//
//  PlayerSectionHeader.swift
//  Playtube
//
//  Created by Ubaid Javaid on 5/26/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PlayerSectionHeader: UITableViewHeaderFooterView {
  
    @IBOutlet weak var upNextLabel: UILabel!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    
    @IBAction func autoPlaySwitchAction(_ sender: UISwitch) {
        UserDefaults.standard.setAutoPlay(value: sender.isOn)
    }
    
}
