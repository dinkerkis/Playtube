//
//  SendCommentCell.swift
//  Playtube
//
//  Created by iMac on 30/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol SendCommentCellDelegate {
    func handleSendButtonTap(_ sender: UIButton, commentTextField: UITextField)
}

class SendCommentCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var commentTextField: UITextField!
    
    // MARK: - Properties
    
    var delegate: SendCommentCellDelegate?
    
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
    
    // Send Button Action
    @IBAction func sendButtonAction(_ sender: UIButton) {
        self.delegate?.handleSendButtonTap(sender, commentTextField: self.commentTextField)
    }
        
}
