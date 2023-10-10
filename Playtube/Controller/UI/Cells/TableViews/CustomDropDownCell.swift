//
//  CustomDropDownCell.swift
//  Playtube
//
//  Created by iMac on 26/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import DropDown

class CustomDropDownCell: DropDownCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var radioImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
