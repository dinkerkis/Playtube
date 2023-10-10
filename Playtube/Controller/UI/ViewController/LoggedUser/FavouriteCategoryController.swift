//
//  FavouriteCategoryController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class FavouriteCategoryController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var fav_cat: [CategoryStruct] = []
    var delegete : FavCategoryDelegate?
    
    var cat_ids = [String]()
    var cate_name = [String]()
    var selectedIndex = [Int]()
    var selectIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FavouriteCatCell", bundle: nil), forCellReuseIdentifier: "FavCatCell")
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for (key,value) in  AppInstance.instance.categories{
            let cat1 = CategoryStruct(cat_Name: value, cate_id: key)
            self.fav_cat.append(cat1)
        }
        self.tableView.reloadData()
    }
    
    @IBAction func Close(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegete?.fav_cat(id: self.cat_ids, name: self.cate_name)
        }
    }
    
}

extension FavouriteCategoryController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.fav_cat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = self.fav_cat[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCatCell") as! FavouriteCatCell
        cell.CatName.text = index.cat_Name
        if (self.selectIndex == indexPath.row){
        if (self.selectedIndex.contains(indexPath.row)){
            self.selectedIndex.removeAll(where: {$0 == indexPath.row})
            self.cate_name.removeAll(where: {$0 == index.cat_Name})
            self.cat_ids.removeAll(where: {$0 == index.cate_id})
            print(self.selectedIndex)
            cell.checkImage.image = UIImage(named: "checkbox-1")
        }
        else{
            self.selectedIndex.append(indexPath.row)
            self.cate_name.append(index.cat_Name)
            self.cat_ids.append(index.cate_id)
            cell.checkImage.image = UIImage(named: "ticks")
            print(self.selectedIndex)
        }
    }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    
}
