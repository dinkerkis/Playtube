//
//  StockCell.swift
//  Playtube
//
//  Created by iMac on 18/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer
import SDWebImage
import PlaytubeSDK

class StockCell: UICollectionViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var videoTypeImage: UIImageView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var verifiedBadge: UIImageView!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            thumbnailImageView,
            videoTypeImage,
            durationView,
            nameLabel,
            userNamelabel,
            optionButton,
            verifiedBadge
        ]
    }
    var object: VideoDetail?
    
    // MARK: - Initialize Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }
    
    // MARK: - Selectors
    
    @IBAction func optionButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.popups.videoOptionPopupVC()
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        newVC?.object = self.object
        (obj_appDelegate.window?.rootViewController as? UINavigationController)?.present(newVC!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    func bind(_ object: VideoDetail) {
        self.object = object
        self.nameLabel.text = object.title?.htmlAttributedString ?? ""
        self.userNamelabel.text = object.owner?.username?.htmlAttributedString ?? ""
        self.verifiedBadge.isHidden = (object.owner?.verified ?? 0) != 1
        self.durationLabel.text = object.duration ?? ""
        if object.source == "YouTube" || object.source == "youtu" || object.video_type == "VideoObject/youtube" {
            self.videoTypeImage.image = UIImage(named: "square-youtube")
        } else if object.source == "Vimeo" {
            self.videoTypeImage.image = UIImage(named: "vimeo")
        } else if object.source == "Dailymotion" {
            self.videoTypeImage.image = UIImage(named: "dailymotion")
        } else {
            if object.is_short == 1 {
                self.videoTypeImage.image = UIImage(named: "square-video")
            } else {
                self.videoTypeImage.image = nil
            }
        }
        let thumbnailImage = URL(string: object.thumbnail ?? "")
        self.thumbnailImageView.sd_setShowActivityIndicatorView(true)
        self.thumbnailImageView.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbnailImageView.sd_setImage(with: thumbnailImage , placeholderImage: R.image.maxresdefault())
        }
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension StockCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
