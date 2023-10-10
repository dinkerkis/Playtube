//
//  PaidVideoView.swift
//  Playtube
//
//  Created by iMac on 09/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol PaidVideoViewDelegate {
    func handlePaidVideoButtonTap(_ sender: UIButton)
}

class PaidVideoView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var paidButton: UIButton!
    
    // MARK: - Properties
    
    var delegate: PaidVideoViewDelegate?
    
    // MARK: - View Initialize Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.initialConfig()
    }
    
    func initialConfig() {
        Bundle.main.loadNibNamed("PaidVideoView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }
    
    // MARK: - Selectors
    
    // Subscribe Button Action
    @IBAction func paidVideoButtonAction(_ sender: UIButton) {
        self.delegate?.handlePaidVideoButtonTap(sender)
    }
    
    // MARK: - Helper Functions
    
    func setupPaidVideoView(for content: VideoDetail) {
        var sell_video = 0.0
        switch content.sell_video {
        case .integer(let value as NSNumber):
            sell_video = value.doubleValue
        case .string(let value as NSString):
            sell_video = value.doubleValue
        case .double(let value):
            sell_video = value
        default:
            break
        }
        if sell_video > 0 {
            self.titleLabel.text = "This video is being sold, you have to rent the video to watch it"
            self.paidButton.setTitle("Purchase $\(sell_video)", for: .normal)
        } else {
            self.titleLabel.text = "Subscribe for $\(content.owner?.subscriber_price ?? "") and unlock all videos"
            self.paidButton.setTitle("Subscribe $\(content.owner?.subscriber_price ?? "")", for: .normal)
        }
    }
    
}
