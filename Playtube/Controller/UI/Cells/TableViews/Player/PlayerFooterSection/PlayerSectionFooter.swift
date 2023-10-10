//
//  FooterSectionView.swift
//  Playtube
//
//  Created by Ubaid Javaid on 6/2/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import FittedSheets

class PlayerSectionFooter: UITableViewHeaderFooterView {
    
    @IBOutlet weak var commentsLbl: UILabel!
    
    var tabBarController: TabbarController!
    var VideoId: Int? = nil
    
    
    @IBAction func TappedBtn (_ sender: UIButton){
        print("BTngiugiu")
        let Storyboards  = UIStoryboard(name: "Player", bundle: nil)
        let playerCommentsVC = Storyboards.instantiateViewController(withIdentifier: "PlayerCommentVC") as! PlayerCommentVC
        playerCommentsVC.videoID = VideoId
        let sheet = SheetViewController(controller: playerCommentsVC, sizes: [.fixed(420), .intrinsic])
        sheet.shouldDismiss = { _ in
            // This is called just before the sheet is dismissed. Return false to prevent the build in dismiss events
            return true
        }
        sheet.didDismiss = { _ in
            // This is called after the sheet is dismissed
        }
        self.tabBarController?.present(sheet, animated: false, completion: nil)
    }
}
