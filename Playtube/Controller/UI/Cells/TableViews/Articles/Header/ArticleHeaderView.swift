//
//  ArticleHeaderView.swift
//  Playtube
//
//  Created by iMac on 03/07/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class ArticleHeaderView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!

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
        Bundle.main.loadNibNamed("ArticleHeaderView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }

}
