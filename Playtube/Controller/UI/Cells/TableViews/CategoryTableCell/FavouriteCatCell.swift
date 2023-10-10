//
//  FavouriteCatCell.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class FavouriteCatCell: UITableViewCell {
    
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var CatName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
