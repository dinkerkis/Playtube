//
//  PaidVideoController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/16/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK
import Async
import Toast_Swift

class PaidVideoController: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPaidVideoLabel: UILabel!
    @IBOutlet weak var showStack: UIStackView!
    
    // MARK: - Properties
    
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var paidVideos: [VideoDetail] = []
    var isStatusBarHidden: Bool = false {
        didSet {
            if oldValue != self.isStatusBarHidden {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.initialConfig()
        
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
        
    //MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.noPaidVideoLabel.text = NSLocalizedString("No paid videos found", comment: "No paid videos found")
        self.registerCell()
        isLoading = true
        self.getVideos()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getVideos()
        }
    }
    
    private func getVideos() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                PaidVideosManager.sharedInstance.getPaidVideos { (success, authError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success")
                                if let data = success?.videos {
                                    self.paidVideos = AppInstance.instance.getNotInterestedData(data: data)
                                }
                                if !self.paidVideos.isEmpty {
                                    self.showStack.isHidden = true
                                    self.tableView.isHidden = false
                                } else {
                                    self.showStack.isHidden = false
                                    self.tableView.isHidden = true                                    
                                }
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                            }
                        }
                    } else if authError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("sessionError = \(authError?.errors?.error_text ?? "")")
                                self.view.makeToast(authError?.errors?.error_text ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            log.debug("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: Table View Setup
extension PaidVideoController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.paidVideos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
            let object = self.paidVideos[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isLoading {
            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            let videoObject = self.paidVideos[indexPath.row]
            let newVC = self.tabBarController as! TabbarController
            newVC.statusBarHiddenDelegate = self
            newVC.handleOpenVideoPlayer(for: videoObject)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: StatusBarHiddenDelegate
extension PaidVideoController: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension PaidVideoController {
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        get {
            return .slide
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
}
