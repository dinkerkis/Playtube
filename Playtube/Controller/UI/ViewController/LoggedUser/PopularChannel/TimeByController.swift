//
//  TimeByController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/8/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class TimeByController: UIViewController {
    
    @IBOutlet weak var timeByLbl: UILabel!
    @IBOutlet weak var todayLbl: UIButton!
    @IBOutlet weak var thisWeekLbl: UIButton!
    @IBOutlet weak var thisMonthLbl: UIButton!
    @IBOutlet weak var thisYearLbl: UIButton!
    @IBOutlet weak var allTimeLbl: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    var delegate : TimeByDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeByLbl.text = NSLocalizedString("Time By", comment: "Time By")
        self.todayLbl.setTitle(NSLocalizedString("Today", comment: "Today"), for: .normal)
        self.thisWeekLbl.setTitle(NSLocalizedString("This Week", comment: "This Week"), for: .normal)
        self.thisMonthLbl.setTitle(NSLocalizedString("This Month", comment: "This Month"), for: .normal)
        self.thisYearLbl.setTitle(NSLocalizedString("This Year", comment: "This Year"), for: .normal)
        self.allTimeLbl.setTitle(NSLocalizedString("All Time", comment: "All Time"), for: .normal)
        self.closeBtn.setTitle(NSLocalizedString("Close", comment: "Close"), for: .normal)
    }
    
    
    @IBAction func Buttons(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            self.dismiss(animated: true) {
                self.delegate?.timeFilter(time: "today")
            }
        case 1:
            self.dismiss(animated: true) {
                self.delegate?.timeFilter(time: "this_week")
            }
        case 2:
            self.dismiss(animated: true) {
                self.delegate?.timeFilter(time: "this_month")
            }
        case 3:
            self.dismiss(animated: true) {
                self.delegate?.timeFilter(time: "this_year")
            }
        case 4:
            self.dismiss(animated: true) {
                self.delegate?.timeFilter(time: "all_time")
            }
        default:
            print("Nothing")
        }
    }
    

    @IBAction func Close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
