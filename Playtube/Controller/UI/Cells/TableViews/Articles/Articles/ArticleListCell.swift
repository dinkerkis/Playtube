//
//  ArticleListCell.swift
//  Playtube
//
//  Created by iMac on 04/07/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer

class ArticleListCell: UITableViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var categorylabel: UILabel!
    @IBOutlet weak var isVerified: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var vc : BaseVC?
    var userData: Owner?
    var shimmeringAnimatedItems: [UIView] {
        [
            categorylabel,
            isVerified,
            usernameLabel,
            titleLabel,
            thumbnailImage
        ]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.textColor = .label
        self.thumbnailImage.roundCorners(corners: [.topLeft, .bottomLeft], radius: 12.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ object: Article) {
        self.userData = object.user_data
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        self.usernameLabel.text = object.user_data?.name ?? ""
        self.showCategory(cateId: object.category ?? "")
        self.isVerified.isHidden = object.user_data?.verified != 1
        let thumbnailImage = URL(string: object.image ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailImage, placeholderImage: R.image.maxresdefault())
    }
    
    func showCategory(cateId: String) {
        if cateId == "1" {
            self.categorylabel.text = "Film & Animation" + "   "
        } else if cateId == "3" {
            self.categorylabel.text = "Music" + "   "
        } else if cateId == "4" {
            self.categorylabel.text = "Pets & Animals" + "   "
        } else if cateId == "5" {
            self.categorylabel.text = "Sports" + "   "
        } else if cateId == "6" {
            self.categorylabel.text = "Travel & Events" + "   "
        } else if cateId == "7" {
            self.categorylabel.text = "Gaming" + "   "
        } else if cateId == "8" {
            self.categorylabel.text = "People & Blogs" + "   "
        } else if cateId == "9" {
            self.categorylabel.text = "Comedy" + "   "
        } else if cateId == "10" {
            self.categorylabel.text = "Entertainment" + "   "
        } else if cateId == "11" {
            self.categorylabel.text = "News & Politics" + "   "
        } else if cateId == "12" {
            self.categorylabel.text = "How-to & Style" + "   "
        } else if cateId == "13" {
            self.categorylabel.text = "Non-profits & Activism" + "   "
        } else if cateId == "other" {
            self.categorylabel.text = "Other" + "   "
        }
    }
    
}
