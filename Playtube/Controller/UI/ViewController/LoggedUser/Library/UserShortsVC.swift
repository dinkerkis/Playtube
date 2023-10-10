//
//  UserShortsVC.swift
//  Playtube
//
//  Created by iMac on 26/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import GoogleMobileAds
import Refreshable
import Toast_Swift

protocol UserShortsVCDelegate: AnyObject {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
}

class UserShortsVC: BaseVC {
    
    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataStack: UIStackView!
    
    // MARK: - Properties
    
    weak var delegate: UserShortsVCDelegate?
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var shortsVideosArray: [VideoDetail] = []
    var channelId: Int? = 0
    var parentContorller: NewUserChannelVC!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        isLoading = true
        self.getUserShortsData()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.profileShortsCell), forCellReuseIdentifier: R.reuseIdentifier.profileShortsCell.identifier)
        self.tableView.setLoadMoreEnable(true)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getUserShortsData()
        }
    }
    
    static func userShortsVC() -> UserShortsVC {
        let newVC = R.storyboard.library.userShortsVC()
        return newVC!
    }
    
    func getUserShortsData() {
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        if Connectivity.isConnectedToNetwork() {
//            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            Async.background {
                ShortsManager.instance.getUserShortsData(User_id: userID, Session_Token: sessionID, profile_id: (self.channelId ?? 0), Limit: 10, Offset: "0", completionBlock: { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog { [self] in
                                log.debug("success")
                                self.shortsVideosArray = []
                                if let data = success?.data {
                                    self.shortsVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                                }
                                if !self.shortsVideosArray.isEmpty {
                                    self.noDataStack.isHidden = true
                                    self.tableView.isHidden = false
                                } else {
                                    self.noDataStack.isHidden = false
                                    self.tableView.isHidden = true
                                }
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    } else {
                        log.error("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
}

// MARK: - Extensions

// MARK: TableView Setup
extension UserShortsVC: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.shortsVideosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileShortsCell.identifier, for: indexPath) as! ProfileShortsCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileShortsCell.identifier, for: indexPath) as! ProfileShortsCell
            let object = self.shortsVideosArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}

// MARK: UIScrollViewDelegate
extension UserShortsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: self.tableView)
    }
    
}
