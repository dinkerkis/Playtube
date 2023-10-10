//
//  PopularChannelController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/7/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK
import SDWebImage
import UIView_Shimmer
import FittedSheets
import Refreshable
import Toast_Swift

class PopularChannelController: BaseVC, ChannelFilterDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private static var pageSize = 15
    private var currentPage = 0
    private var lastPage = 0
    var channels: [Channels] = []
    var controller : SheetViewController?
    private var isLoading = true {
        didSet {
            tableView.reloadData()
        }
    }
    var type = "views"
    var sort = "all_time"
    
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
    
    // Filter Button Action
    @IBAction func filterButtonAction(_ sender: UIButton) {
        //        let Storyboards = UIStoryboard(name: "LoggedUser", bundle: nil)
        if let vc = R.storyboard.loggedUser.channelFilterVC() {
            //Storyboards.instantiateViewController(withIdentifier: "ChannelFilterVC") as! PopularChannelFilterController
            vc.sortStr = self.type
            vc.timeStr = self.sort
            vc.delegate = self
            var bottomPadding = 0
            if #available(iOS 11.0, *) {
                bottomPadding = Int(self.view.safeAreaInsets.top)
            }
            if bottomPadding == 44 {
                self.controller = SheetViewController(controller: vc, sizes: [.fixed(456)])
            } else {
                self.controller = SheetViewController(controller: vc, sizes: [.fixed(422)])
            }
            self.controller?.dismissOnOverlayTap = true
            self.present(self.controller!, animated: false, completion: nil)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        isLoading = true
        self.getChannels()
        self.tableView.addPullRefresh { [weak self] in
            PopularChannelController.pageSize = 15
            self?.currentPage = 0
            self?.lastPage = 0
            self?.isLoading = true
            self?.getChannels()
        }
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.prefetchDataSource = self
        }
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(resource: R.nib.popularCell), forCellReuseIdentifier: R.reuseIdentifier.popularCell.identifier)
    }
    
    private func getChannelsLoadMore(indx: Int) {
        if (Connectivity.isConnectedToNetwork()) {
            let targetCount = currentPage < 0 ? 0 : (currentPage + 1) * PopularChannelController.pageSize - 10
            guard indx == targetCount else {
                return
            }
            currentPage += 1
            let arrIds = NSMutableArray()
            for data in self.channels {
                if let user_data = data.user_data {
                    if let id = user_data.id {
                        arrIds.add(id)
                    }
                }
            }
            let strIds = arrIds.componentsJoined(by: ",")
            var lastCount = 0
            switch self.channels[self.channels.count-1].count {
            case .integer(let value as NSNumber):
                lastCount = value.intValue
            case .string(let value as NSString):
                lastCount = value.integerValue
            default:
                break
            }
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            GetPopularPostManager.sharedInstance.getPopularPost(type: self.type, sortType: self.sort, limit: 15, lastCount: lastCount, channelIds: strIds) { (success, authError, error) in
                if (success != nil) {
                    self.lastPage += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.tableView.beginUpdates()
                        for i in success?.channels ?? [] {
                            self.tableView.insertRows(at: [IndexPath(row: self.channels.count, section: 0)], with: .automatic)
                            self.channels.append(i)
                        }
                        self.tableView.endUpdates()
                    }
                } else if (authError != nil) {
                    self.isLoading = false
                    self.view.makeToast(authError?.errors?.error_text)
                } else if (error != nil) {
                    self.isLoading = false
                    self.view.makeToast(error?.localizedDescription)
                }
            }
            
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    private func getChannels() {
        if (Connectivity.isConnectedToNetwork()) {
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            GetPopularPostManager.sharedInstance.getPopularPost(type: self.type, sortType: self.sort, limit: 15, lastCount: 0, channelIds: "") { (success, authError, error) in
                if (success != nil) {
                    self.dismissProgressDialog {
                        self.channels = []
                        self.channels = success?.channels ?? []
                        self.isLoading = false
                        self.tableView.stopPullRefreshEver()
                    }
                } else if (authError != nil) {
                    self.dismissProgressDialog {
                        self.view.makeToast(authError?.errors?.error_text)
                    }
                } else if (error != nil) {
                    self.dismissProgressDialog {
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func filter(sort_by: String, time_by: String) {
        self.type = sort_by
        self.sort = time_by
        self.channels.removeAll()
        self.isLoading = true
        PopularChannelController.pageSize = 15
        self.currentPage = 0
        self.lastPage = 0
        self.getChannels()
    }
    
    func viewModel(at index: Int) -> Channels? {
        guard index >= 0 && index < self.channels.count else { return nil }
        /*print("Index :=> ",index, self.channels.count)*/
        self.getChannelsLoadMore(indx : index)
        return self.channels[index]
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension PopularChannelController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.channels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.popularCell.identifier) as! PopularCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.popularCell.identifier) as! PopularCell
            if let index = self.viewModel(at: indexPath.row) {
                guard let object = index.user_data else { return cell }
                cell.bind(object)
            }
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let newVC = R.storyboard.library.newUserChannelVC()
            newVC?.channelData = self.channels[indexPath.row].user_data
            self.navigationController?.pushViewController(newVC!, animated: true)
            /*let newVC = R.storyboard.loggedUser.newProfileVC()
            newVC?.isPopularVC = true
            newVC?.channalData = self.channels[indexPath.row].user_data
            self.navigationController?.pushViewController(newVC!, animated: true)*/
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: UITableViewDataSourcePrefetching
extension PopularChannelController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.channels.count == 0 {
                return
            }
            if let _ = self.viewModel(at: (indexPath as NSIndexPath).row) {
                print(String.init(format: "prefetchRowsAt #%i", indexPath.row))
            }
        }
    }
    
}

// MARK: PopularCellDelegate
extension PopularChannelController: PopularCellDelegate {
    
    func handleSubscribeChannel() {
        self.currentPage = 0
        self.lastPage = 0
        self.getChannels()
    }
    
}
