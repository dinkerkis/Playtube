//
//  ProfileShortsCell.swift
//  Playtube
//
//  Created by iMac on 27/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer
import SDWebImage

class ProfileShortsCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var shortsImage: UIView!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var verifiedBadge: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            thumbnailImage,
            shortsImage,
            titleLabel,
            optionButton,
            usernameLabel,
            verifiedBadge,
            viewsLabel
        ]
    }
    var object: VideoDetail?
    
    // MARK: - Initialize Functions

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Selectors
    
    // Option Button Action
    @IBAction func optionButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.popups.videoOptionPopupVC()
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        newVC?.object = self.object
        obj_appDelegate.window?.rootViewController?.present(newVC!, animated: true)
    }
    
    func bind(_ object: VideoDetail) {
        self.object = object
        self.titleLabel.text = object.title!.htmlAttributedString ?? ""
        self.viewsLabel.text = "\(object.views!.roundedWithAbbreviations) Views"
        self.usernameLabel.text = object.owner!.username!.htmlAttributedString ?? ""
        self.verifiedBadge.isHidden = (object.owner?.verified ?? 0) != 1
        let thumbnailImage = URL(string: object.thumbnail ?? "")
        self.thumbnailImage.sd_setShowActivityIndicatorView(true)
        self.thumbnailImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbnailImage.sd_setImage(with: thumbnailImage , placeholderImage: R.image.maxresdefault())
        }
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension ProfileShortsCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
