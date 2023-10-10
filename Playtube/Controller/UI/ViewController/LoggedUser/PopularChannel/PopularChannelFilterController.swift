//
//  PopularChannelFilterController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/8/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PopularChannelFilterController: UIViewController{//,TimeByDelegate,SortByDelegate{
    
    
    //    @IBOutlet weak var sortLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var sortByLabel: UILabel!
//    @IBOutlet weak var timeByLbl: UILabel!
//    @IBOutlet weak var filterLabel: UILabel!
//    @IBOutlet weak var resetBtn: UIButton!

    @IBOutlet weak var filterBtn: RoundButton!
    var delegate: ChannelFilterDelegate?
    
    var sortStr = "views"
    var timeStr = "today"
    
    @IBOutlet weak var btnSubscribers: UIButton!
    @IBOutlet weak var btnViews: UIButton!
    @IBOutlet weak var btnMostActive: UIButton!
    
    @IBOutlet weak var btnToday: UIButton!
    @IBOutlet weak var btnWeek: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var btnAll: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.sortByLabel.text = NSLocalizedString("Sort By", comment: "Sort By")
//        self.timeByLbl.text = NSLocalizedString("Time By", comment: "Time By")
//        self.resetBtn.setTitle(NSLocalizedString("RESET", comment: "RESET"), for: .normal)
//        self.filterBtn.setTitle(NSLocalizedString("APPLY FILTER", comment: "APPLY FILTER"), for: .normal)
//        self.filterLabel.text = NSLocalizedString("Filter", comment: "Filter")
        if self.sortStr == "views" {
            self.btnViews(btnViews!)
        }else if self.sortStr == "subscribers" {
            self.btnSubscribers(btnSubscribers!)
        }else if self.sortStr == "most_active" {
            self.btnMostActive(btnMostActive!)
        }
                
        if self.timeStr == "today" {
            self.btnToday(btnToday!)
        }else if self.timeStr == "this_week" {
            self.btnWeek(btnWeek!)
        }else if self.timeStr == "this_month" {
            self.btnMonth(btnMonth!)
        }else if self.timeStr == "this_year" {
            self.btnYear(btnYear!)
        }else if self.timeStr == "all_time" {
            self.btnAll(btnAll!)
        }
    }
    
    func sortBackgroundClear()
    {
        self.btnViews.backgroundColor = .white
        self.btnViews.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnSubscribers.backgroundColor = .white
        self.btnSubscribers.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnMostActive.backgroundColor = .white
        self.btnMostActive.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
    }
    
    func timeBackgroundClear()
    {
        self.btnToday.backgroundColor = .white
        self.btnToday.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnWeek.backgroundColor = .white
        self.btnWeek.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnMonth.backgroundColor = .white
        self.btnMonth.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnYear.backgroundColor = .white
        self.btnYear.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnAll.backgroundColor = .white
        self.btnAll.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
    }
    
    @IBAction func btnToday(_ sender: Any) {
        self.timeBackgroundClear()
        self.timeStr = "today"
        self.btnToday.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnToday.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnWeek(_ sender: Any) {
        self.timeBackgroundClear()
        self.timeStr = "this_week"
        self.btnWeek.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnWeek.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnMonth(_ sender: Any) {
        self.timeBackgroundClear()
        self.timeStr = "this_month"
        self.btnMonth.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnMonth.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnYear(_ sender: Any) {
        self.timeBackgroundClear()
        self.timeStr = "this_year"
        self.btnYear.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnYear.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnAll(_ sender: Any) {
        self.timeBackgroundClear()
        self.timeStr = "all_time"
        self.btnAll.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnAll.setTitleColor(.white, for: .normal)
    }
    
    
    @IBAction func btnReset(_ sender: Any) {
        self.sortBackgroundClear()
        self.timeBackgroundClear()
        self.sortStr = "views"
        self.timeStr = "today"
        self.btnViews.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnViews.setTitleColor(.white, for: .normal)
        self.btnToday.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnToday.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnViews(_ sender: Any) {
        self.sortBackgroundClear()
        self.sortStr = "views"
        self.btnViews.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnViews.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnSubscribers(_ sender: Any) {
        self.sortBackgroundClear()
        self.sortStr = "subscribers"
        self.btnSubscribers.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnSubscribers.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnMostActive(_ sender: Any) {
        self.sortBackgroundClear()
        self.sortStr = "most_active"
        self.btnMostActive.backgroundColor = UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1)
        self.btnMostActive.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func ApplyFilter(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.filter(sort_by: self.sortStr, time_by: self.timeStr)
        }
    }
    
    /*@IBAction func Reset(_ sender: Any) {
        self.sortLabel.text = "most_active"
        self.timeLabel.text = "today"
    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func Sort(_ sender: Any) {
    let Storyboards = UIStoryboard(name: "LoggedUser", bundle: nil)
    let vc = Storyboards.instantiateViewController(withIdentifier: "SortByVC") as! SortByController
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func Time(_ sender: Any) {
    let Storyboards = UIStoryboard(name: "LoggedUser", bundle: nil)
    let vc = Storyboards.instantiateViewController(withIdentifier: "TimeByVC") as! TimeByController
    vc.delegate = self
    vc.modalPresentationStyle = .overFullScreen
    vc.modalTransitionStyle = .crossDissolve
    self.present(vc, animated: true, completion: nil)
        
    }
    
    func timeFilter(time: String) {
        self.timeLabel.text = time
    }
    
    func SortFilter(sort: String) {
        self.sortLabel.text = sort
    }*/
}
