//
//  SortByController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/8/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SortByController: UIViewController {
    
    
    @IBOutlet weak var viewsLabel: UIButton!
    @IBOutlet weak var subscriberLbl: UIButton!
    @IBOutlet weak var mostActive: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var sortByLbl: UILabel!
    
    var delegate: SortByDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewsLabel.setTitle(NSLocalizedString("Views", comment: "Views"), for: .normal)
        self.subscriberLbl.setTitle(NSLocalizedString("Subscriber", comment: "Subscriber"), for: .normal)
        self.mostActive.setTitle(NSLocalizedString("Most Active", comment: "Most Active"), for: .normal)
        self.sortByLbl.text = NSLocalizedString("Sort By", comment: "Sort By")
        self.closeBtn.setTitle(NSLocalizedString("Close", comment: "Close"), for: .normal)

    }
    
    
    
    @IBAction func Buttons(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            self.dismiss(animated: true) {
                self.delegate?.SortFilter(sort: "views")
            }
        case 1:
            self.dismiss(animated: true) {
                self.delegate?.SortFilter(sort: "subscribers")
            }
        case 2:
            self.dismiss(animated: true) {
                self.delegate?.SortFilter(sort: "most_active")
            }
        default:
            print("Nothing")
        }
    }
    
    @IBAction func Close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
