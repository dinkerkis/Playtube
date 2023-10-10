//
//  ActivitesController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/16/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Toast_Swift

class ActivitesController: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var noView: UIView!
    
    // MARK: - Properties
        
    var activites: [UserActivity] = []
    private var isLoading = true
        
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noView.isHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.userActivityCell), forCellReuseIdentifier: R.reuseIdentifier.userActivityCell.identifier)
        isLoading = true
    }
    
    static func activitesController() -> ActivitesController {
        let newVC = R.storyboard.loggedUser.activityVC()
        return newVC!
    }
    
    // MARK: - Helper Functions
    @objc func video_Upload(notification: NSNotification) {
        let parentViewController = self.parent as! NewProfileVC
    }
    
    private func getActivites(limit: Int, offset: Int) {
        if (Connectivity.isConnectedToNetwork()) {
            UserActivityManager.sharedInstance.getActivity(limit: 30, offsetInt: 0, profileId: (AppInstance.instance.userId ?? 0)) { (success, authError, error) in
                if (success != nil) {
                    self.dismissProgressDialog {
                        self.activites = []
                        self.activites = success?.data ?? []
                    }
                    if (self.activites.count == 0) || (self.activites.isEmpty == true){
                        self.noView.isHidden = false
                        self.tableView.isHidden = true
                    } else {
                        self.noView.isHidden = true
                        self.tableView.isHidden = false
                    }
                    self.isLoading = false
                    itemsCount = self.activites.count
                    self.tableView.stopPullRefreshEver()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        NotificationCenter.default.post(name: NSNotification.Name("ReloadContainerView"), object: nil)
                    }
                     self.tableView.reloadData()
                } else if (authError != nil) {
                    self.view.makeToast(authError?.errors?.error_text)
                } else if (error != nil) {
                    self.view.makeToast(error?.localizedDescription)
                }
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.isLoading = false
            if self.activites.isEmpty {
                print("showTableView")
                self.isLoading = false
                self.noView.isHidden = false
                self.tableView.isHidden = true
            }else{
                self.isLoading = false
                print("showStack")
                self.noView.isHidden = true
                self.tableView.isHidden = false
            }
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension ActivitesController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.activites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userActivityCell.identifier, for: indexPath) as! UserActivityCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userActivityCell.identifier, for: indexPath) as! UserActivityCell
            let index = self.activites[indexPath.row]
            cell.bind(index: index)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 370
    }
    
}
