//
//  VideoOptionCell.swift
//  Playtube
//
//  Created by iMac on 02/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class VideoOptionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(content: String) {
        self.titleLabel.text = content
        switch content {
        case "Save to watch later":
            self.optionImageView.image = UIImage(named: "Outline_Time_Circle")
        case "Save to playlist":
            self.optionImageView.image = UIImage(named: "Outline_Plus")
        case "Download video":
            self.optionImageView.image = UIImage(named: "Outline_Download")
        case "Share":
            self.optionImageView.image = UIImage(named: "Outline_Upload")
        case "Not interested":
            self.optionImageView.image = UIImage(named: "Outline_Delete")
        case "Report":
            self.optionImageView.image = UIImage(named: "")
        default:
            break
        }
    }
    
}
