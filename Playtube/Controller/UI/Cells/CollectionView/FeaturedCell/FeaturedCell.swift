//
//  FeaturedCell.swift
//  Playtube
//
//  Created by iMac on 06/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer

class FeaturedCell: UICollectionViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            backgroundImage,
            usernameLabel,
            titleLabel
        ]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    // MARK: - Helper Functions
    
    func bind(_ object: VideoDetail) {
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        self.usernameLabel.text = (object.owner?.username?.htmlAttributedString ?? "") + " | \(object.views ?? 0) Views | \(object.time_ago ?? "")"
        let thumbnailURL = URL(string: object.thumbnail ?? "")
        self.backgroundImage.sd_setShowActivityIndicatorView(true)
        self.backgroundImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.backgroundImage.sd_setImage(with: thumbnailURL , placeholderImage: R.image.maxresdefault())
        }
    }

}
