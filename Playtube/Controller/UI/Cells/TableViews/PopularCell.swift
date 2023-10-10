//
//  PopularCell.swift
//  Playtube
//
//  Created by iMac on 25/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer
import Async
import Toast_Swift

protocol PopularCellDelegate {
    func handleSubscribeChannel()
}

class PopularCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var subscriberLabel: UILabel!
    @IBOutlet weak var profileImage: RoundImage!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var verifiedBadge: UIImageView!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            userName,
            subscriberLabel,
            profileImage,
            subscribeButton,
            verifiedBadge
        ]
    }
    var object: Owner?
    var delegate: PopularCellDelegate?
    
    // MARK: - Initialize View

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Selectors
    
    // Subscribe Button Action
    @IBAction func subscribeButtonAction(_ sender: UIButton) {
        subscribeChannel()
    }
    
    // MARK: - Helper Functions
    
    func bind(_ object: Owner) {
        self.object = object
        self.userName.text = object.name
        let profileImage = URL(string: object.avatar ?? "")
        self.profileImage.sd_setShowActivityIndicatorView(true)
        self.profileImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        }
        switch object.subscribe_count {
        case .integer(let value):
            self.subscriberLabel.text = "\(value) Subscribers"
        case .string(let value):
            self.subscriberLabel.text = "\(value) Subscribers"
        default:
            break
        }
        self.verifiedBadge.isHidden = (object.verified ?? 0) != 1
        if object.am_i_subscribed == 0 {
            self.subscribeButton.setTitle("Subscribe", for: .normal)
            self.subscribeButton.backgroundColor = UIColor(named: "Primary_UI_Primary")?.withAlphaComponent(0.1)
            self.subscribeButton.setTitleColor(UIColor(named: "Primary_UI_Primary"), for: .normal)
        } else {
            self.subscribeButton.setTitle("Subscribed", for: .normal)
            self.subscribeButton.backgroundColor = UIColor(named: "Fill_Colors_Secondary")
            self.subscribeButton.setTitleColor(UIColor(named: "Label_Colors_Secondary"), for: .normal)
        }
    }
    
    func subscribeChannel() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.object?.id ?? 0
            Async.background {
                PlayVideoManager.instance.subUnsubChannel(User_id: userID, Session_Token: sessionID, Channel_Id: channelID) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            if success?.code == 0 {
                                obj_appDelegate.window?.rootViewController?.view.makeToast("Unsubscribed Successfully")
                                /*self.subscribeButton.setTitle("Subscribe", for: .normal)
                                self.subscribeButton.backgroundColor = UIColor(named: "Primary_UI_Primary")?.withAlphaComponent(0.1)
                                self.subscribeButton.setTitleColor(UIColor(named: "Primary_UI_Primary"), for: .normal)*/
                            } else {
                                obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Subscribed Successfully", comment: "Subscribed Successfully"))
                                /*self.subscribeButton.setTitle("Subscribed", for: .normal)
                                self.subscribeButton.backgroundColor = UIColor(named: "Fill_Colors_Secondary")
                                self.subscribeButton.setTitleColor(UIColor(named: "Label_Colors_Secondary"), for: .normal)*/
                            }
                            self.delegate?.handleSubscribeChannel()
                        }
                    } else if sessionError != nil {
                        log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(sessionError?.errors!.error_text ?? "")
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
