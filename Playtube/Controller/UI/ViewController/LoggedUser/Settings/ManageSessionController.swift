//
//  ManageSessionController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/7/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK
import Toast_Swift

class ManageSessionController: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var sessionArray: [SessionData] = []
    private var isLoading = true {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.isLoading = true
        self.getSessions()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.menageSessionCell), forCellReuseIdentifier: R.reuseIdentifier.menageSessionCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getSessions()
        }
    }
    
    private func getSessions() {
        if Connectivity.isConnectedToNetwork() {
            SessionManager.sharedInstance.getSession { (success, authError, error) in
                if (success != nil) {
                    self.sessionArray = []
                    self.sessionArray = success?.data ?? []
                    self.isLoading = false
                    self.tableView.stopPullRefreshEver()
                } else if authError != nil {
                    self.dismissProgressDialog {
                        self.view.makeToast(authError?.errors?.error_text)
                    }
                } else if error != nil {
                    self.dismissProgressDialog {
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func deleteSession(id: Int, index: Int) {
        if Connectivity.isConnectedToNetwork() {
            SessionManager.sharedInstance.deleteSession(id: id) { (success, authError, error) in
                if success != nil {
                    self.sessionArray.remove(at: index)
                    self.tableView.reloadData()
                } else if (authError != nil) {
                    self.view.makeToast(authError?.errors?.error_text)
                } else if (error != nil) {
                    self.view.makeToast(error?.localizedDescription)
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension ManageSessionController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.sessionArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.menageSessionCell.identifier, for: indexPath) as! MenageSessionCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.menageSessionCell.identifier, for: indexPath) as! MenageSessionCell
            let index = self.sessionArray[indexPath.row]
            cell.delegate = self
            cell.closeButton.tag = indexPath.row
            cell.bind(content: index)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: MenageSessionCellDelegate Methods
extension ManageSessionController: MenageSessionCellDelegate {
    
    func handleCloseButtonTap(_ sender: UIButton) {
        let warningPopupVC = R.storyboard.popups.warningPopupVC()
        warningPopupVC?.delegate = self
        warningPopupVC?.messageText = "Are you sure you want to log out from this device?"
        self.present(warningPopupVC!, animated: true, completion: nil)
        warningPopupVC?.okButton.tag = sender.tag
    }
    
}

// MARK: WarningPopupVCDelegate Methods
extension ManageSessionController: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton) {
        let content = self.sessionArray[sender.tag]
        self.deleteSession(id: content.id ?? 0 ,index: sender.tag)
    }
    
}
