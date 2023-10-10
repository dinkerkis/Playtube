//
//  CategoryCell.swift
//  Playtube
//
//  Created by iMac on 17/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer

struct CategoryStruct {
    var cat_Name: String
    var cate_id: String
}

class CategoryCell: UICollectionViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var shimmeringAnimatedItems: [UIView] {
        [
            backView
        ]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

}
