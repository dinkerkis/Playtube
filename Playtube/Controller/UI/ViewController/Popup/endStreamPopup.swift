//
//  endStreamPopup.swift
//  Playtube
//
//  Created by Muhammad's Macbook pro on 26/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class endStreamPopup: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    var vc: LiveStreamController?
    var delegate: EndStream?
    var commnet:String?
    var views:String?
    var lenght:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.5)
        self.stopLabel.text = NSLocalizedString("Ready to stop live streaming?", comment: "Ready to stop live streaming?")
        self.titleLabel.text = NSLocalizedString("", comment: "")
        self.yesButton.setTitle(NSLocalizedString("YES", comment: "YES"), for: .normal)
        self.noButton.setTitle(NSLocalizedString("NO", comment: "NO"), for: .normal)
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        let vc = R.storyboard.live.endLiveStreamVC()
        vc?.vc = self
        vc?.commnet = commnet
        vc?.lenght = lenght
        vc?.views = views
        
        vc?.delegate = self.delegate
        vc?.modalPresentationStyle = .overCurrentContext
        self.vc?.deleteLive(postId: self.vc?.post_id ?? "" ?? "")
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func noClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
