//
//  MoviesCell.swift
//  Playtube
//
//  Created by Abdul Moid on 18/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class MoviesCell: UICollectionViewCell {
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieDespView: UIView!
    @IBOutlet weak var movieImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
