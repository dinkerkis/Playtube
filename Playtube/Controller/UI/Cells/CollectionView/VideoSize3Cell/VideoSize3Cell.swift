//
//  VideoSize3Cell.swift
//  Playtube
//
//  Created by iMac on 17/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer
import SDWebImage

class VideoSize3Cell: UICollectionViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var videoTypeImage: UIImageView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            thumbnailImage,
            videoTypeImage,
            titleLabel,
            userNamelabel,
            timeView,
            durationLabel,
            optionButton
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
        obj_appDelegate.window?.rootViewController?.present(newVC!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    func bind(_ object: VideoDetail) {
        self.object = object
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        self.userNamelabel.text = object.owner?.username?.htmlAttributedString ?? ""
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
        self.thumbnailImage.sd_setShowActivityIndicatorView(true)
        self.thumbnailImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbnailImage.sd_setImage(with: thumbnailImage , placeholderImage:R.image.maxresdefault())
        }
    }

}

// MARK: UIViewControllerTransitioningDelegate Methods
extension VideoSize3Cell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
