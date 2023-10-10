//
//  CategoryPopupVC.swift
//  Playtube
//
//  Created by Abdul Moid on 25/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class CategoryPopupVC: BaseVC {
    
    var array = [String]()
    var vc:MoviesFilterVC?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        self.showProgressDialog(text: "Loading...")
        fetchCategory()
        
        
        self.categoryLabel.text = NSLocalizedString("Category", comment: "Category")
        self.closeButton.setTitle(NSLocalizedString("Close", comment: "Close"), for: .normal)
    }
    
    func fetchCategory(){
        GetSettingsManager.instance.getSetting { (categories, settings,success, sessionError, error) in
            if settings != nil{
                if let movies_categories = (settings as! NSDictionary).object(forKey: "movies_categories") as? NSDictionary
                {
                    if let cat = movies_categories.object(forKey: "514") as? String
                    {
                        self.array.append(cat)
                    }
                    if let cat = movies_categories.object(forKey: "other") as? String
                    {
                        self.array.append(cat)
                    }
                }
//                let data1 = settings.data//data?.siteSettings.moviesCategories
//                self.array.append(data1?.the514 ?? "")
//                self.array.append(data1?.other ?? "")
                self.dismissProgressDialog {
                    self.tableView.reloadData()
                }
            }else if sessionError != nil{
                self.vc?.view.makeToast("\(sessionError)")
            }else {
                log.error("error  = \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CategoryPopupVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = array[indexPath.item]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if array.isEmpty == false {
            self.dismiss(animated: true) {
                self.vc?.categoryTextField.text = self.array[indexPath.item]
            }
        }
    }
}
