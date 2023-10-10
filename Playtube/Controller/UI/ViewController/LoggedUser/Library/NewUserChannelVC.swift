//
//  NewUserChannelVC.swift
//  Playtube
//
//  Created by iMac on 25/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Toast_Swift
import Async
import PlaytubeSDK

class NewUserChannelVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Properties

    var navigationView = UIView()
    var headerView = UserChannelHeaderView()
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TopLeft"
        label.textColor = .white
        return label
    }()
    var channelData: Owner?
    var pageMenu: CAPSPageMenu!
    var userChannelVideosVC: UserChannelVideosVC = UserChannelVideosVC.userChannelVideosVC()
    var userShortsVC: UserShortsVC = UserShortsVC.userShortsVC()
    var userChannelPlaylistVC: UserChannelPlaylistVC = UserChannelPlaylistVC.userChannelPlaylistVC()
    var aboutVC: AboutVC = AboutVC.aboutVC()
    var userActivitiesVC: UserActivitiesVC = UserActivitiesVC.userActivitiesVC()
    var controllerArray: [UIViewController] = []
    var childScrollView = UIScrollView()
    
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
    
    // Search Button Action
    @IBAction func searchButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.loggedUser.searchVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    // Chat Button Action
    @IBAction func chatButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.chat.chatScreenVC()
        vc?.recipentID = channelData?.id ?? 0
        vc!.username = channelData?.username ?? ""
        vc!.userImg = channelData?.avatar ?? ""
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupHeaderView()
        self.setupPageMenu()
    }

    // Setup Header View
    func setupHeaderView() {
        self.scrollView.delegate = self
        self.headerView = UserChannelHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 349))
        self.headerView.delegate = self
        self.headerView.channelData = self.channelData
        self.headerView.setData()
        self.scrollView.stickyHeader.view = headerView
        self.scrollView.stickyHeader.height = headerView.frame.height
        self.scrollView.stickyHeader.minimumHeight = 48
        
        navigationView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        navigationView.backgroundColor = UIColor(named: "Primary_UI_Primary")
        navigationView.alpha = 0
        self.scrollView.stickyHeader.view = navigationView
        
        self.navigationView.addSubview(headerLabel)
        headerLabel.text = channelData?.username ?? ""
        headerLabel.font =  UIFont(name: "TTCommons-Medium", size: 18.0)
        headerLabel.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: -10.0).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 48.0).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
    }
    
    // setup Pagemenu
    func setupPageMenu() {
        self.userChannelVideosVC.parentContorller = self
        self.userChannelVideosVC.channelId = self.channelData?.id ?? 0
        self.userChannelVideosVC.delegate = self
        self.controllerArray.append(self.userChannelVideosVC)
        
        self.userShortsVC.parentContorller = self
        self.userShortsVC.channelId = self.channelData?.id ?? 0
        self.userShortsVC.delegate = self
        self.controllerArray.append(self.userShortsVC)
        
        self.userChannelPlaylistVC.parentContorller = self
        self.userChannelPlaylistVC.delegate = self
        self.userChannelPlaylistVC.channelID = self.channelData?.id ?? 0
        self.controllerArray.append(self.userChannelPlaylistVC)
        
        self.userActivitiesVC.parentContorller = self
        self.userActivitiesVC.delegate = self
        self.userActivitiesVC.channelID = self.channelData?.id ?? 0
        self.controllerArray.append(self.userActivitiesVC)
        
        self.aboutVC.channelID = self.channelData?.id ?? 0
        self.aboutVC.channelData = self.channelData!
        self.aboutVC.parentVC = self
        self.controllerArray.append(self.aboutVC)
        
        let parameters: [CAPSPageMenuOption] = [
            .menuHeight(00)
        ]
        self.pageMenu = CAPSPageMenu(viewControllers: self.controllerArray, frame: CGRect(x: 0.0, y: 0.0, width: self.containerView.bounds.width, height: self.containerView.bounds.height), pageMenuOptions: parameters)
        self.pageMenu.delegate = self
        self.containerView.addSubview(self.pageMenu.view!)
        self.pageMenu.moveToPage(0)
    }

    func subscribeChannel() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.channelData?.id ?? 0
            Async.background {
                PlayVideoManager.instance.subUnsubChannel(User_id: userID , Session_Token: sessionID, Channel_Id: channelID) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.verbose("success \(success?.code ?? 0) ")
                            if success?.code == 0 {
                                self.view.makeToast("Unsubscribed Successfully")
                                self.headerView.subscribeButton.setTitle("+ Subscribe", for: .normal)
                            } else {
                                self.view.makeToast(NSLocalizedString("Subscribed Successfully", comment: "Subscribed Successfully"))
                                self.headerView.subscribeButton.setTitle("✓ Subscribed", for: .normal)
                            }
                        }
                    } else if sessionError != nil {
                        log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                        self.view.makeToast(sessionError?.errors!.error_text ?? "")
                    } else {
                        log.verbose("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: UIScrollViewDelegate
extension NewUserChannelVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let changeStartOffset: CGFloat = -100.0
        let changeSpeed: CGFloat = 50.0
        self.navigationView.alpha = min(1.0, (offset - changeStartOffset) / changeSpeed)
        if self.scrollView.contentOffset.y > (self.scrollView.contentSize.height - self.scrollView.bounds.height) {
            self.childScrollView.isScrollEnabled = true
            // print("True 3")
        } else {
            if self.scrollView.contentOffset.y <= 0 {
                self.childScrollView.isScrollEnabled = true
                // print("True 4")
            } else {
                self.childScrollView.isScrollEnabled = false
                // print("False 3")
            }
        }
    }
    
}

// MARK: UserChannelHeaderViewDelegate
extension NewUserChannelVC: UserChannelHeaderViewDelegate {
    
    func handleSubscribeButtonTap(sender: UIButton) {
        self.subscribeChannel()
    }
    
    func handleDidSelectItemAt(indexPath: IndexPath) {
        if self.pageMenu.currentPageIndex != indexPath.item {
            self.pageMenu.moveToPage(indexPath.item)
        }
    }
    
}

// MARK: CAPSPageMenuDelegate
extension NewUserChannelVC: CAPSPageMenuDelegate {
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        self.headerView.selectedIndex = index
        self.headerView.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        self.headerView.collectionView.reloadData()
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        self.headerView.selectedIndex = index
        self.headerView.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        self.headerView.collectionView.reloadData()
    }
    
}

// MARK: UserChannelVideosVCDelegate
extension NewUserChannelVC: UserChannelVideosVCDelegate, UserShortsVCDelegate, UserChannelPlaylistVCDelegate, UserActivitiesVCDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView) {
        self.childScrollView = scrollView
        if scrollView.contentOffset.y <= 0 {
            if self.scrollView.contentOffset.y >= -48.0 {
                tableView.isScrollEnabled = false
                // print("False 1")
            } else {
                tableView.isScrollEnabled = true
                // print("True 1")
            }
        } else {
            if self.scrollView.contentOffset.y >= (self.scrollView.contentSize.height - self.scrollView.bounds.height) {
                tableView.isScrollEnabled = true
                // print("True 2")
            } else {
                tableView.isScrollEnabled = false
                // print("False 2")
            }
        }
        // print("Child Scroll View", scrollView.contentOffset.y)
        // print( "Main Scroll View", self.scrollView.contentOffset.y )
    }
    
    func videoCount(count: Int) {
        self.headerView.videosLabel.text = "\(count)"
    }
    
}
