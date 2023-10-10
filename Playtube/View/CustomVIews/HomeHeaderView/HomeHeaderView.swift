//
//  HomeHeaderView.swift
//  Playtube
//
//  Created by iMac on 13/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol HomeHeaderViewDelegate {
    func handleSignInMessageTap(sender: UIButton)
}

class HomeHeaderView: UIView {
    
    // MARK: - IBOutlets

    @IBOutlet weak var contentView: UIView!
    
    // MARK: - Properties
    
    var delegate: HomeHeaderViewDelegate?
    
    // MARK: - Initialize Function

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Initial Code
        
        self.setInitialLayout()
    }
    
}

// MARK: - Layout Methods
extension HomeHeaderView {
    
    // MARK: - Selectors
    
    // Sign In Message Button Action
    @IBAction func signInMessageButtonAction(_ sender: UIButton) {
        self.delegate?.handleSignInMessageTap(sender: sender)        
    }
    
    // MARK: - Helper Functions

    func setInitialLayout() {
        Bundle.main.loadNibNamed("HomeHeaderView", owner: self, options: nil)
        self.contentView.isOpaque = false
        addSubview(self.contentView)
        self.contentView.frame = self.bounds
    }

}
