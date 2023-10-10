//
//  TrendingCell.swift
//  Playtube
//
//  Created by iMac on 19/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import DropDown
import UIView_Shimmer
import PlaytubeSDK

class TrendingCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var videoTypeImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var verifiedBadge: UIImageView!
    
    // MARK: - Properties
    
    private var dropDown = DropDown()
    var object: VideoDetail?
    var shimmeringAnimatedItems: [UIView] {
        [
            thumbnailImage,
            videoTypeImage,
            profileImage,
            titleLabel,
            usernameLabel,
            timeView,
            optionButton,
            verifiedBadge
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
    
    // MARK: - Selectors
    
    @IBAction func morePressed(_ sender: UIButton) {
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
        self.usernameLabel.text = object.owner?.username?.htmlAttributedString ?? ""
        self.verifiedBadge.isHidden = (object.owner?.verified ?? 0) != 1
        self.timeLabel.text = object.duration ?? ""
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
        let profileImage = URL(string: object.owner?.avatar ?? "")
        self.profileImage.sd_setShowActivityIndicatorView(true)
        self.profileImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        }
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension TrendingCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
