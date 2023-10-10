//
//  UserActivityCell.swift
//  Playtube
//
//  Created by iMac on 29/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer
import SDWebImage
import Async
import PlaytubeSDK
import Toast_Swift

protocol UserActivityCellDelegate {
    func handleSendButtonTap(_ sender: UIButton, object: UserActivity?)
}

class UserActivityCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var captionTxt: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Properties
    
    var object: UserActivity?
    var shimmeringAnimatedItems: [UIView] {
        [
            mainImage,
            likeImage,
            likeCount,
            likeButton,
            likeView,
            commentImage,
            commentCount,
            commentButton,
            commentView,
            sendButton,
            captionTxt,
            timeLabel
        ]
    }
    var delegate: UserActivityCellDelegate?
    
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
    
    // Like Button Action
    @IBAction func likeButtonAction(_ sender: UIButton) {
        if (object?.is_liked ?? 0) == 0 {
            self.likeDisLikeActivity(type: "like")
        } else {
            self.likeDisLikeActivity(type: "dislike")
        }
    }
    
    // Comment Button Action
    @IBAction func commentButtonAction(_ sender: UIButton) {
        print("Comment Button Tapped")
    }
    
    // Send Button Action
    @IBAction func sendButtonAction(_ sender: UIButton) {
        self.delegate?.handleSendButtonTap(sender, object: self.object)
    }
    
    // MARK: - Helper Functions
    
    func bind(index: UserActivity) {
        self.object = index
        if (index.is_liked ?? 0) == 0 {
            self.likeImage.image = UIImage(named: "Outline_ant_design_heart_filled")
        } else {
            self.likeImage.image = UIImage(named: "Bold_ant_design_heart_filled")
        }
        self.timeLabel.text = index.time_text ?? ""
        self.captionTxt.text = index.text ?? ""
        let url = URL(string: (index.image ?? ""))
        self.mainImage.sd_setShowActivityIndicatorView(true)
        self.mainImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.mainImage.sd_setImage(with: url , placeholderImage:R.image.maxresdefault())
        }
        self.likeCount.text = "\(index.likes ?? 0)"
        self.commentCount.text = "\(index.comments_count ?? 0)"
    }

}

// MARK: Extensions

// MARK: Api Call
extension UserActivityCell {
    
    func likeDisLikeActivity(type: String) {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                UserActivityManager.sharedInstance.likeDislikeActivity(type: type, id: (self.object?.id ?? 0)) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            if success?.success_type == "dislike_activity" {
                                self.object?.likes! -= 1
                                self.likeCount.text = "\(self.object?.likes ?? 0)"
                                self.object?.is_liked = 0
                                self.likeImage.image = UIImage(named: "Outline_ant_design_heart_filled")
                                obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Disliked", comment: "Disliked"))
                            } else {
                                self.object?.likes! += 1
                                self.likeCount.text = "\(self.object?.likes ?? 0)"
                                self.object?.is_liked = 1
                                self.likeImage.image = UIImage(named: "Bold_ant_design_heart_filled")
                                obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Liked", comment: "Liked"))
                            }
                            log.verbose(success?.success_type ?? "")
                        }
                    } else if sessionError != nil {
                        log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(sessionError?.errors?.error_text ?? "")
                    } else {
                        log.verbose("error = \(error?.localizedDescription ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            }
        } else {
            obj_appDelegate.window?.rootViewController?.view.makeToast("InterNetError")
        }
    }
    
}

