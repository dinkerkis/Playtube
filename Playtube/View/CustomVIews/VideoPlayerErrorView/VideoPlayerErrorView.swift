//
//  VideoPlayerErrorView.swift
//  Playtube
//
//  Created by iMac on 12/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class VideoPlayerErrorView: UIView {
    
    // MARK: - IBOutlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
        Bundle.main.loadNibNamed("VideoPlayerErrorView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }
    
    // MARK: - Helper Functions
    
    func setupsVideoPlayerErrorView(errorImage: UIImage?, description: String) {
        self.errorImageView.image = errorImage
        self.descriptionLabel.text = description
    }
    
}
