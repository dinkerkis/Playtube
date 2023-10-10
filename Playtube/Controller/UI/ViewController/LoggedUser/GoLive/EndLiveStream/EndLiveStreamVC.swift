//
//  EndLiveStreamVC.swift
//  Playtube
//
//  Created by Muhammad's Macbook pro on 26/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class EndLiveStreamVC: UIViewController {

    var commnet:String?
    var views:String?
    var lenght:String?
    
    var delegate: EndStream?
    var vc: endStreamPopup?
    @IBOutlet weak var lenghtCountLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var lenghtLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var secLabe: UILabel!
    @IBOutlet weak var streamLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentsCountLabel.text = commnet
        self.viewCountLabel.text = views
        self.lenghtCountLabel.text = lenght
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.vc?.vc?.view.alpha = 0
        self.vc?.view.alpha = 0
        self.dismiss(animated: true) {
            self.vc?.dismiss(animated: true, completion: {
                self.vc?.vc?.dismiss(animated: true, completion: nil)
            })
        }
    }
}
