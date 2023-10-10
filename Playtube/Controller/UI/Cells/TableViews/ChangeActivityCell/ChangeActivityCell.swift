//
//  ChangeActivityCell.swift
//  Playtube
//
//  Created by iMac on 15/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer

class ChangeActivityCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var captionTxt: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentView: UIView!
    
    // MARK: - Properties
    
    var object: VideoDetail?
    var vc: ActivitesController?
    var activity_id: Int? = nil
    var isLiked: Int? = nil
    var shimmeringAnimatedItems: [UIView] {
        [
            timeLabel,
            captionTxt,
            mainImage,
            likeBtn,
            likeView,
            commentBtn,
            commentView,
            likeImage,
            lblLikeCount,
            commentImage,
            lblCommentCount
        ]
    }
    
    // MARK: - View Life Cycles

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: - Selectors -
    @IBAction func likeButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction func commentButtonAction(_ sender: UIButton) {
        
    }
    
    // MARK: - Helper Functions
    
    func bind(index: [String: Any]) {
        if let id = index["id"] as? Int {
            self.activity_id = id
        }
        
        if let isLike = index["is_liked"] as? Int {
            self.isLiked = isLike
            if isLike == 0 {
                self.likeImage.image = UIImage(named: "Hearts")
            } else {
                self.likeImage.image = UIImage(named: "like_new-1")
            }
        }
       
        if let time = index["time_text"] as? String {
            self.timeLabel.text = time
        }
        if let caption = index["text"] as? String {
            self.captionTxt.attributedText = caption.convertHtmlToNSAttributedString
        }
        if let image = index["image"] as? String {
            let url = URL(string: image)
            self.mainImage.sd_setShowActivityIndicatorView(true)
            self.mainImage.sd_setIndicatorStyle(.medium)
            DispatchQueue.global(qos: .userInteractive).async {
                self.mainImage.sd_setImage(with: url , placeholderImage:R.image.maxresdefault())
            }
        }
        if let likes = index["likes"] as? Int {
            self.lblLikeCount.text = "\(likes)"
        }
       
        if let commentCount = index["comments_count"] as? Int {
            self.lblCommentCount.text = "\(commentCount)"
        }
    }
    
}
