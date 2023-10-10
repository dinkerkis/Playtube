//
//  ChannelsVC.swift
//  Playtube
//
//  Created by iMac on 01/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import Toast_Swift

class ChannelsVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var isLoading = true {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var subscribedChannelArray: [Owner] = []
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        self.fetchSubscribedChannels()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.popularCell), forCellReuseIdentifier: R.reuseIdentifier.popularCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.fetchSubscribedChannels()
        }
    }

}

// MARK: - Extensions

// MARK: Api Call
extension ChannelsVC {
    
    private func fetchSubscribedChannels() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            LibraryManager.instance.getSubscribedChannels(user_id: userID, session_Token: sessionID, channel: 1, limit: 100) { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        log.debug("Success")
                        self.subscribedChannelArray = []
                        self.subscribedChannelArray = success?.data ?? []
                        self.isLoading = false
                        self.tableView.stopPullRefreshEver()
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup
extension ChannelsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return 10
        } else {
            return self.subscribedChannelArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoading {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.popularCell.identifier, for: indexPath) as! PopularCell
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.popularCell.identifier, for: indexPath) as! PopularCell
            let object = self.subscribedChannelArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let newVC = R.storyboard.library.newUserChannelVC()
            newVC?.channelData = self.subscribedChannelArray[indexPath.row]
            self.navigationController?.pushViewController(newVC!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}
