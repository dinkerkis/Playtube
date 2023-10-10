//
//  UpgradeUserCell.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/12/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class UpgradeUserCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var proType: UILabel!
    @IBOutlet weak var featuredLabel: UILabel!
    @IBOutlet weak var profileVisitorLabel: UILabel!
    @IBOutlet weak var hideLastSeenLabel: UILabel!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var postPromotionLabel: UILabel!
    @IBOutlet weak var pagePromotionLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var upgradeBtn: RoundButton!
    
    // MARK: - Properties
    
    var vc: UpgradeVC?
    var type: String? = ""
    
    // MARK: - Selectors
    
    @IBAction func UpgradeNow(_ sender: Any) {
        if type == "0" {
            self.vc?.navigationController?.popViewController(animated: true)
        } else {
            self.vc!.startCheckout()
        }
    }
    
}
