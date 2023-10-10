//
//  UserActivitiesVC.swift
//  Playtube
//
//  Created by iMac on 29/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Toast_Swift

protocol UserActivitiesVCDelegate: AnyObject {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
}

class UserActivitiesVC: BaseVC {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var noView: UIView!
    
    // MARK: - Properties
    
    weak var delegate: UserActivitiesVCDelegate?
    var parentContorller: NewUserChannelVC!
    var activites: [UserActivity] = []
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var channelID: Int? = 0
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.noView.isHidden = true
        isLoading = true
        self.getActivites(limit: 30, offset: 0)
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.userActivityCell), forCellReuseIdentifier: R.reuseIdentifier.userActivityCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getActivites(limit: 30, offset: 0)
        }
    }
    
    static func userActivitiesVC() -> UserActivitiesVC {
        let newVC = R.storyboard.library.userActivitiesVC()
        return newVC!
    }
    
    private func getActivites(limit: Int, offset: Int) {
        if (Connectivity.isConnectedToNetwork()) {
            UserActivityManager.sharedInstance.getActivity(limit: limit, offsetInt: offset, profileId: (self.channelID ?? 0)) { (success, authError, error) in
                if (success != nil) {
                    self.dismissProgressDialog {
                        self.activites = []
                        self.activites = success?.data ?? []
                        if (self.activites.count == 0) || (self.activites.isEmpty == true){
                            self.noView.isHidden = false
                            self.tableView.isHidden = true
                        } else {
                            self.noView.isHidden = true
                            self.tableView.isHidden = false
                        }
                        self.isLoading = false
                        self.tableView.stopPullRefreshEver()
                    }
                    
                } else if (authError != nil) {
                    self.view.makeToast(authError?.errors?.error_text)
                } else if (error != nil) {
                    self.view.makeToast(error?.localizedDescription)
                }
            }
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension UserActivitiesVC: UITableViewDelegate, UITableViewDataSource {
    
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
            cell.delegate = self
            let index = self.activites[indexPath.row]
            cell.bind(index: index)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let cell = tableView.cellForRow(at: indexPath) as! UserActivityCell
            let newVC = R.storyboard.library.activityDetailsVC()
            newVC?.activity = cell.object
            self.parentContorller.navigationController?.pushViewController(newVC!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 370
    }
    
}

// MARK: UIScrollViewDelegate
extension UserActivitiesVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: self.tableView)
    }
    
}

// MARK: UserActivityCellDelegate
extension UserActivitiesVC: UserActivityCellDelegate {
    
    func handleSendButtonTap(_ sender: UIButton, object: UserActivity?) {
        let newVC = R.storyboard.library.activityDetailsVC()
        newVC?.activity = object
        self.parentContorller.navigationController?.pushViewController(newVC!, animated: true)
    }
    
}
