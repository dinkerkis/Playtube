//
//  CategoryFilterController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/3/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

struct SearchFilterModel {
    let title: String?
    let parameter: String?
}

protocol SearchFilterVCDelegate {
    func handleSearchFilter(searchData: SearchFilterModel)
}

class SearchFilterVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var searchFilterArray: [SearchFilterModel] = []
    var delegate: SearchFilterVCDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.addSearchFilterData()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.searchFilterCell), forCellReuseIdentifier: R.reuseIdentifier.searchFilterCell.identifier)
    }
    
    // Add Search Filter Data
    func addSearchFilterData() {
        self.searchFilterArray = [
            SearchFilterModel(title: "Last Hour", parameter: "last_hour"),
            SearchFilterModel(title: "Today", parameter: "today"),
            SearchFilterModel(title: "This Week", parameter: "this_week"),
            SearchFilterModel(title: "This Month", parameter: "this_month"),
            SearchFilterModel(title: "This Year", parameter: "this_year")
        ]
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension SearchFilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchFilterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchFilterCell.identifier, for: indexPath) as! SearchFilterCell
        cell.titleLabel.text = self.searchFilterArray[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.handleSearchFilter(searchData: self.searchFilterArray[indexPath.row])
        }
    }
    
}
