//
//  CreatePopupCell.swift
//  Playtube
//
//  Created by iMac on 15/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class CreatePopupCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var mainView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
