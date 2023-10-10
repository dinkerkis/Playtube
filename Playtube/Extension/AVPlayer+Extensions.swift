//
//  AVPlayer+Extensions.swift
//  Playtube
//
//  Created by iMac on 21/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import UIKit
import AVKit

extension AVPlayer {
    
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
    
    var icon: UIImage {
        let imageName = isPlaying ? "bold_ic_round_pause" : "bold_play_arrow"
        let image = UIImage(named: imageName)
        return image ?? UIImage()
    }
    
}
