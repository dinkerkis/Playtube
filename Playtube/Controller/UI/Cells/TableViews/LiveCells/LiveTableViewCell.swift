//
//  LiveTableViewCell.swift
//  Playtube
//
//  Created by Abdul Moid on 29/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class LiveTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
        backgroundColor = .clear
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
