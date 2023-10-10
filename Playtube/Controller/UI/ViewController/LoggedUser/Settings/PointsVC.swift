//
//  PointsVC.swift
//  Playtube
//
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PointsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
