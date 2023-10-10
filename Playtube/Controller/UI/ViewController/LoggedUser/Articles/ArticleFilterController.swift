//
//  ArticleFilterController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/11/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK

extension Dictionary {
    subscript(i: Int) -> (key: Key, value: Value) {
        return self[index(startIndex, offsetBy: i)]
    }
}

class ArticleFilterController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var catLbl: UILabel!
    @IBOutlet weak var getArticleLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    var category = [CategoryStruct]()
    
    var delegate: ArticleCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.catLbl.text = NSLocalizedString("Selecte a Category", comment: "Selecte a Category")
        self.getArticleLbl.text = NSLocalizedString("Get articles by categories", comment: "Get articles by categories")
        self.closeBtn.setTitle(NSLocalizedString("Close", comment: "Close"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
             let defa = CategoryStruct(cat_Name: "Default", cate_id: "")
             let popular = CategoryStruct(cat_Name: "Most Popular", cate_id: "")
              self.category.append(defa)
              self.category.append(popular)
        
        for (key,value) in  AppInstance.instance.categories{
            let cat1 = CategoryStruct(cat_Name: value, cate_id: key)
            self.category.append(cat1)
        }
             
    }
    
    @IBAction func Close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ArticleFilterController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let index = self.category[indexPath.row]
        cell.textLabel?.text = index.cat_Name
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.font = UIFont(name: "ariel", size: 17.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let index = self.category[indexPath.row]
            if (indexPath.row == 1){
                self.delegate?.articalCat(id: index.cate_id, url: API.Articles_Methods.MOST_POPULAR_ARTICLES_API)
            }
            else{
                self.delegate?.articalCat(id: index.cate_id, url: API.Articles_Methods.FETCH_ARTICLES_API)
            }
        }
    }
    
    
    
    
}
