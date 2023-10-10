//
//  MenageSessionCell.swift
//  Playtube
//
//  Created by iMac on 22/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer

protocol MenageSessionCellDelegate {
    func handleCloseButtonTap(_ sender: UIButton)
}

class MenageSessionCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var platform: UILabel!
    @IBOutlet weak var browserLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var imgPlatform: RoundImage!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Properties

    var shimmeringAnimatedItems: [UIView] {
        [
            platform,
            browserLabel,
            lastSeenLabel,
            imgPlatform,
            closeButton
        ]
    }
    var delegate: MenageSessionCellDelegate?
    
    // MARK: - View Life Cycle Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.delegate?.handleCloseButtonTap(sender)
    }
    
    // MARK: - Helper Functions
    
    func bind(content: SessionData) {
        self.platform.text = content.platform
        if content.platform == "Phone" {
            self.imgPlatform.image = UIImage(named: "phone_new")
            self.browserLabel.text = "Mobile Browser"
        } else {
            self.imgPlatform.image = UIImage(named: "web_new")
            self.browserLabel.text = "Desktop Browser"
        }
        self.lastSeenLabel.text = "Last seen: \(content.time ?? "")"
        /*if let platform_details = index["platform_details"] as? [String: Any] {
            if let name = platform_details["name"] as? String {
                self.browserLabel.text = name
            }
        }*/
    }
    
}
