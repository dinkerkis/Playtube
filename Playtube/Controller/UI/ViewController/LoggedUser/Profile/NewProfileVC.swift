//
//  NewProfileVC.swift
//  Playtube
//
//  Created by iMac on 20/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import PlaytubeSDK

var itemsCount = 0

class NewProfileVC: BaseVC {
    
    @IBOutlet weak var tableView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    
    var navigationView = UIView()
    var headerView = ProfileHeaderView()
    var tabSelectedHandler:((Int) -> ())?
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TopLeft"
        label.textColor = .white
        return label
    }()
    var channelVideos = [VideoDetail]()
    var shortsVideosArray: [VideoDetail] = []
    var playlistsArray = [PlaylistModel.MyAllPlaylist]()
    var activites: [UserActivity] = []
    
    var changeVideosVC: ChangeVideosVC = ChangeVideosVC.changeVideosVC()
    var profileShortsVC: ProfileShortsVC = ProfileShortsVC.profileShortsVC()
    var channelPlaylistVC: ChannelPlaylistVC = ChannelPlaylistVC.channelPlaylistVC()
    var aboutVC: AboutVC = AboutVC.aboutVC()
    var activitesController: ActivitesController = ActivitesController.activitesController()
    var controllerArray : [UIViewController] = []
    var pageController = UIPageViewController()
    var channalData: Owner?
    var isPopularVC = false
    var videoLimitCount = 10
    var shortLimitCount = 10
    var activitiesLimitCount = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSetting.isHidden = AppInstance.instance.userId != channalData?.id
        btnChat.isHidden = AppInstance.instance.userId == channalData?.id
        btnSearch.isHidden = AppInstance.instance.userId == channalData?.id
        
        if AppInstance.instance.userId == channalData?.id {
            self.tabBarController?.tabBar.isHidden = true
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ReloadContainerView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContainerView), name: NSNotification.Name("ReloadContainerView"), object: nil)
        self.initialConfig()
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.beginRefreshing()
        
        self.tableView.refreshControl = refreshControl
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if AppInstance.instance.userId == channalData?.id {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    // Setting Button Action
    @IBAction func settingButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.settings.settingVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    // Setting Button Action
    @IBAction func searchButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.loggedUser.searchVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    // Setting Button Action
    @IBAction func chatButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.chat.chatScreenVC()
//        vc?.UserData = self.channalData
        vc?.recipentID = self.channalData?.id ?? 0
        if (self.channalData?.first_name ?? "").isEmpty && (self.channalData?.last_name ?? "").isEmpty {
            vc?.username = self.channalData?.name ?? ""
        } else {
            vc?.username = (self.channalData?.first_name ?? "") + (self.channalData?.last_name ?? "")
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
//        if AppInstance.instance.userId == self.channalData?.id {
            self.navigationController?.popViewController(animated: true)
//        }else{
//            self.navigationController?.popToRootViewController(animated: true)
//        }        
    }
}

extension NewProfileVC {
    @objc func refreshData() {
        self.tableView.refreshControl?.beginRefreshing()
        let count = headerView.selectedIndex
        if count == 0 {
            self.fetchMyChannelVideos()
        }else if count == 1 {
            self.getUserShortsData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "", profileID: self.channalData?.id ?? 0)
        } else if count == 2 {
            if AppInstance.instance.userId == self.channalData?.id {
                self.myChannelPlayListfetchData()
            }else{
                self.getOtherChannelPlayListfetchData()
            }
        }else if count == 3 {
            self.getActivites()
        }
    }
    
    @objc func reloadContainerView() {
        self.containerViewHeight.constant = self.tableViewHeight()
        self.containerView.layoutIfNeeded()
    }
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.getUserProfile()
        self.setupPageViewController()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        headerView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 349))
        headerView.tabsView.delegate = self
        headerView.delegate = self
        self.tableView.stickyHeader.view = headerView
        self.tableView.stickyHeader.height = headerView.frame.height
        self.tableView.stickyHeader.minimumHeight = 48
        
        navigationView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        navigationView.backgroundColor = UIColor(named: "Primary_UI_Primary")
        navigationView.alpha = 0
        self.tableView.stickyHeader.view = navigationView
        
        self.navigationView.addSubview(headerLabel)
        headerLabel.text = self.channalData?.name
        headerLabel.font =  UIFont(name: "TTCommons-Medium", size: 18.0)
        headerLabel.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: -10.0).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 48.0).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
    }
    
    func setupPageViewController() {
        self.controllerArray.append(self.changeVideosVC)
        self.controllerArray.append(self.profileShortsVC)
        self.channelPlaylistVC.parentVC = self
        self.controllerArray.append(self.channelPlaylistVC)
        self.controllerArray.append(self.activitesController)
        self.aboutVC.parentVC = self
        self.controllerArray.append(self.aboutVC)
        
        // PageViewController
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.pageController.delegate = self
        self.pageController.dataSource = self
        self.addChild(self.pageController)
        self.containerView.addSubview(self.pageController.view)
        
        // Set the selected ViewController in the PageViewController when the app starts
        pageController.setViewControllers([controllerArray[0]], direction: .forward, animated: true, completion: nil)
        
        // PageViewController Constraints
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pageController.view.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.pageController.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.pageController.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.pageController.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])
        //        self.pageController.view.backgroundColor = .red
        self.pageController.didMove(toParent: self)
    }
}

//MARK: - API Services -
extension NewProfileVC {
    
    private func getUserProfile() {
        if let channalData = channalData {
            if AppInstance.instance.userId != channalData.id {
                if channalData.am_i_subscribed == 0 {
                    self.headerView.editButton.setTitle("+ Subscribe", for: .normal)
                }else {
                    self.headerView.editButton.setTitle("✓ Subscribed", for: .normal)
                }
            }
            self.headerView.setDataOtherUser(owner: channalData)
        }
        self.fetchMyChannelVideos()
        self.getUserShortsData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "", profileID: self.channalData?.id ?? 0)
        if AppInstance.instance.userId == self.channalData?.id {
            self.myChannelPlayListfetchData()
        }else{
            self.getOtherChannelPlayListfetchData()
        }
        self.getActivites()
    }
    
    private func fetchMyChannelVideos(limit: Int = 10) {
        if Connectivity.isConnectedToNetwork(){
            let userID = self.channalData?.id ?? 0 //AppInstance.instance.userId ?? 0
            MyChannelManager.instance.getChannelVideos(User_id: userID, Offset:0, Limit: limit, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    log.verbose("SUCCESS")
                    self.channelVideos.removeAll()
                    if let data = success?.data {
                        self.channelVideos = AppInstance.instance.getNotInterestedData(data: data)
                    }
                    self.headerView.videosLabel.text = "\(self.channelVideos.count)"
                    self.tableView.refreshControl?.endRefreshing()
                    self.addData()
                    self.reloadContainerView()
                    self.reloadCurrentPage()
                }else if sessionError != nil {
                    self.view.makeToast(sessionError?.errors!.error_text ?? "")
                    log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                }else{
                    self.view.makeToast(error?.localizedDescription ?? "")
                    log.verbose("error = \(error?.localizedDescription ?? "")")
                }
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
    
    func getUserShortsData(UserID: Int, SessionID: String, profileID: Int, limit: Int = 10) {
        if Connectivity.isConnectedToNetwork() {
            ShortsManager.instance.getUserShortsData(User_id: UserID, Session_Token: SessionID, profile_id: profileID, Limit: limit, Offset: "45,44", completionBlock: { success, sessionError, error in
                if success != nil {
                    log.debug("success")
                    self.shortsVideosArray = []
                    if let data = success?.data {
                        self.shortsVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                    }
                    self.tableView.refreshControl?.endRefreshing()
                    self.addData()
                    self.reloadContainerView()
                    self.reloadCurrentPage()
                } else if sessionError != nil {
                    log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                    self.view.makeToast(sessionError?.errors!.error_text)
                } else {
                    log.error("error = \(error?.localizedDescription ?? "")")
                    self.view.makeToast(error?.localizedDescription ?? "")
                }
            })
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    private func myChannelPlayListfetchData(){
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            PlaylistManager.instance.getPlaylist(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    log.debug("success")
                    self.playlistsArray.removeAll()
                    self.playlistsArray = (success?.myAllPlaylists)!
                    self.tableView.refreshControl?.endRefreshing()
                    self.addData()
                    self.reloadContainerView()
                    self.reloadCurrentPage()
//                    self.getActivites()
                }else if sessionError != nil{
                    log.debug("sessionError = \(String(describing: sessionError?.errors?.error_text))")
                    self.view.makeToast(sessionError?.errors?.error_text)
                }else{
                    log.debug("error = \(String(describing: error?.localizedDescription))")
                    self.view.makeToast(error?.localizedDescription)
                }
            })
        }else {
            self.view.makeToast(InterNetError)
        }
    }
    
    private func getOtherChannelPlayListfetchData(){
        if Connectivity.isConnectedToNetwork() {
            let userID = self.channalData?.id ?? 0
//            let sessionID = AppInstance.instance.sessionId ?? ""
            PlaylistManager.instance.getPlaylistWithChannelId(User_id: userID, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    log.debug("success")
                    self.playlistsArray.removeAll()
                    self.playlistsArray = (success?.myAllPlaylists)!
                    self.tableView.refreshControl?.endRefreshing()
                    self.addData()
                    self.reloadContainerView()
                    self.reloadCurrentPage()
//                    self.getActivites()
                }else if sessionError != nil{
                    log.debug("sessionError = \(sessionError?.errors?.error_text ?? "")")
                    self.view.makeToast(sessionError?.errors!.error_text)
                }else{
                    log.debug("error = \(error?.localizedDescription ?? "")")
                    self.view.makeToast(error?.localizedDescription)
                }
            })
        }else {
            self.view.makeToast(InterNetError)
        }
    }
    
    private func getActivites(limit: Int = 10) {
        if (Connectivity.isConnectedToNetwork()) {
            UserActivityManager.sharedInstance.getActivity(limit: 30, offsetInt: 0, profileId: (AppInstance.instance.userId ?? 0)) { (success, authError, error) in
                if (success != nil) {
                    self.activites = []
                    self.activites = success?.data ?? []
                    self.tableView.refreshControl?.endRefreshing()
                    self.addData()
                    self.reloadContainerView()
                    self.reloadCurrentPage()
                } else if (authError != nil) {
                    self.view.makeToast(authError?.errors?.error_text)
                } else if (error != nil) {
                    self.view.makeToast(error?.localizedDescription)
                }
            }
        }
    }
    
    func subscribeChannel() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.channalData?.id ?? 0
            PlayVideoManager.instance.subUnsubChannel(User_id: userID, Session_Token: sessionID, Channel_Id: channelID) { (success, sessionError, error) in
                if success != nil {
                    if success?.code == 0 {
                        obj_appDelegate.window?.rootViewController?.view.makeToast("Unsubscribed Successfully")
                        self.headerView.editButton.setTitle("+ Subscribe", for: .normal)
                    } else {
                        obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Subscribed Successfully", comment: "Subscribed Successfully"))
                        self.headerView.editButton.setTitle("✓ Subscribed", for: .normal)
                    }
                    if self.isPopularVC {
                        NotificationCenter.default.post(name: NSNotification.Name("reloadPopularChannelData"), object: nil)
                    }else {
                        NotificationCenter.default.post(name: NSNotification.Name("reloadShortData"), object: nil)
                    }
                } else if sessionError != nil {
                    log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                    obj_appDelegate.window?.rootViewController?.view.makeToast(sessionError?.errors!.error_text ?? "")
                } else {
                    log.verbose("error = \(error?.localizedDescription ?? "")")
                    obj_appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                }
            }
        } else {
            obj_appDelegate.window?.rootViewController?.view.makeToast("InterNetError")
        }
    }
    
    func addData() {
        changeVideosVC.channelVideos = self.channelVideos
        profileShortsVC.shortsVideosArray = self.shortsVideosArray
        channelPlaylistVC.playlistsArray = self.playlistsArray
        activitesController.activites = self.activites
        aboutVC.channelID = self.channalData?.id
        aboutVC.channelData = self.channalData
    }
    
}

extension NewProfileVC: ProfileHeaderViewDelegate, TabsDelegate, UIScrollViewDelegate {
    
    func editButtonAction(_ sender: UIButton) {
        if AppInstance.instance.userId == self.channalData?.id {
            self.view.endEditing(true)
            let newVC = R.storyboard.settings.editChannelVC()
            self.navigationController?.pushViewController(newVC!, animated: true)
        }else{
//            self.view.makeToast("Coming soon...")
            self.subscribeChannel()
        }
    }
    
    func tableViewHeight() -> CGFloat {
        switch headerView.selectedIndex {
        case 0:
            let count = self.channelVideos.count
            if !(count == 0) {
                return CGFloat(count*120)
            } else {
                return 240.0
            }
        case 1:
            let count = self.shortsVideosArray.count
            if !(count == 0) {
                return CGFloat(count*135)
            }else {
                return 270.0
            }
        case 2:
            let count = self.playlistsArray.count
            if !(count == 0) {
                return CGFloat(count*120)
            }else {
                return 240.0
            }
        case 3:
            let count = self.activites.count
            if !(count == 0) {
                return CGFloat(count*375)
            }else {
                return 375.0
            }
        case 4:
            return (self.aboutVC.view.subviews.first as! UIScrollView).contentSize.height
        default: break
        }
        return 600.0
    }
    
    func tabsViewDidSelectItemAt(position: Int) {
        // Check if the selected tab cell position is the same with the current position in pageController, if not, then go forward or backward
        if position != headerView.selectedIndex {
            if position > headerView.selectedIndex {
                self.pageController.setViewControllers([showViewController(position)!], direction: .forward, animated: true, completion: nil)
            } else {
                self.pageController.setViewControllers([showViewController(position)!], direction: .reverse, animated: true, completion: nil)
            }
            headerView.tabsView.collectionView.scrollToItem(at: IndexPath(item: position, section: 0), at: .centeredHorizontally, animated: true)
            reloadContainerView()
        }
    }
    
    
    // MARK: Scrollview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let changeStartOffset: CGFloat = -75.0
        let changeSpeed: CGFloat = 50.0
        navigationView.alpha = min(1.0, (offset - changeStartOffset) / changeSpeed)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isOnBottom {
            switch headerView.selectedIndex {
            case 0:
                if self.videoLimitCount <= self.channelVideos.count {
                    self.videoLimitCount += 10
                    self.fetchMyChannelVideos(limit: self.videoLimitCount)
                }
            case 1:
                if self.shortLimitCount <= self.shortsVideosArray.count {
                    self.shortLimitCount += 10
                    self.getUserShortsData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "", profileID: self.channalData?.id ?? 0, limit: self.shortLimitCount)
                }
            case 3:
                if self.activitiesLimitCount <= self.activites.count {
                    self.activitiesLimitCount += 10
                    self.getActivites(limit: self.activitiesLimitCount)
                }
            default: break
            }

        }
    }

    func scrollingFinished(scrollView: UIScrollView) {
       // Your code
        print("ending")
    }
}

extension NewProfileVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func reloadCurrentPage() {
        switch headerView.selectedIndex {
        case 0:
            let contentVC = changeVideosVC
            contentVC.reloadTableView()
        case 1:
            let contentVC = profileShortsVC
            contentVC.reloadTableView()
        case 2:
            let contentVC = channelPlaylistVC
            contentVC.reloadTableView()
        case 3:
            let contentVC = activitesController
            contentVC.reloadTableView()
        case 4:
            break
        default: break
        }
    }
    
    
    func showViewController(_ index: Int) -> UIViewController? {
        if (self.headerView.profileTabArray.count == 0) || (index >= self.headerView.profileTabArray.count) {
            return nil
        }
        headerView.selectedIndex = index
        if index == 0 {
            let contentVC = changeVideosVC
            contentVC.view.tag = index
            contentVC.reloadTableView()
            return contentVC
        } else if index == 1 {
            let contentVC = profileShortsVC
            contentVC.view.tag = index
            contentVC.reloadTableView()
            return contentVC
        } else if index == 2 {
            let contentVC = channelPlaylistVC
            contentVC.reloadTableView()
            contentVC.view.tag = index
            return contentVC
        } else if index == 3 {
            let contentVC = activitesController
            contentVC.reloadTableView()
            contentVC.view.tag = index
            return contentVC
        } else if index == 4 {
            let contentVC = aboutVC
            contentVC.viewDidLoad()
            contentVC.view.tag = index
            return contentVC
        } else {
            let contentVC = changeVideosVC
            contentVC.view.tag = index
            return contentVC
        }
    }
    
    // return ViewController when go forward
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = pageViewController.viewControllers?.first
        var index: Int
        index = getVCPageIndex(vc)
        // Don't do anything when viewpager reach the number of tabs
        if index == headerView.profileTabArray.count {
            return nil
        } else {
            index += 1
            return self.showViewController(index)
        }
    }
    
    // return ViewController when go backward
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = pageViewController.viewControllers?.first
        var index: Int
        index = getVCPageIndex(vc)
        
        if index == 0 {
            return nil
        } else {
            index -= 1
            return self.showViewController(index)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            if completed {
                guard let vc = pageViewController.viewControllers?.first else { return }
                let index: Int
                index = getVCPageIndex(vc)
                headerView.tabsView.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredVertically)
                // Animate the tab in the TabsView to be centered when you are scrolling using .scrollable
                headerView.tabsView.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func getVCPageIndex(_ viewController: UIViewController?) -> Int {
        switch viewController {
        case is ChangeVideosVC:
            let vc = viewController as! ChangeVideosVC
            print("contentVC", vc.channelVideos.count)
            let count = vc.channelVideos.count
            self.containerViewHeight.constant = (count == 0) ? 240.0 : CGFloat(count*120)
            return vc.view.tag
        case is ProfileShortsVC:
            let vc = viewController as! ProfileShortsVC
            print("contentVC", vc.shortsVideosArray.count)
            let count = vc.shortsVideosArray.count
            self.containerViewHeight.constant = (count == 0) ? 270.0 : CGFloat(count*135)
            return vc.view.tag
        case is ChannelPlaylistVC:
            let vc = viewController as! ChannelPlaylistVC
            print("contentVC", vc.playlistsArray.count)
            let count = vc.playlistsArray.count
            self.containerViewHeight.constant = (count == 0) ? 240.0 : CGFloat(count*120)
            return vc.view.tag
        case is ActivitesController:
            let vc = viewController as! ActivitesController
            let count = vc.activites.count
            self.containerViewHeight.constant = (count == 0) ? 375.0 : CGFloat(count*375)
            return vc.view.tag
        case is AboutVC:
            let vc = viewController as! AboutVC
            self.containerViewHeight.constant = (vc.view.subviews.first as! UIScrollView).contentSize.height
            return vc.view.tag
        default:
            let vc = viewController as! ChangeVideosVC
            let count = vc.channelVideos.count
            self.containerViewHeight.constant = (count == 0) ? 240.0 : CGFloat(count*120)
            return vc.view.tag
        }
    }
}

extension UIScrollView {
    
    func scrollToTop(animated: Bool = false) {
        setContentOffset(CGPoint(x: contentOffset.x, y: -adjustedContentInset.top), animated: animated)
    }
    
    var bottomContentOffsetY: CGFloat {
        max(contentSize.height - bounds.height + adjustedContentInset.bottom, -adjustedContentInset.top)
    }
    
    func scrollToBottom(animated: Bool = false) {
        setContentOffset(CGPoint(x: contentOffset.x, y: bottomContentOffsetY), animated: animated)
    }
    
    func scrollToLeading(animated: Bool = false) {
        setContentOffset(CGPoint(x: -adjustedContentInset.left, y: contentOffset.y), animated: animated)
    }
    
    var trailingContentOffsetX: CGFloat {
        max(contentSize.width - bounds.width + adjustedContentInset.right, -adjustedContentInset.left)
    }
    
    func scrollToTrailing(animated: Bool = false) {
        setContentOffset(CGPoint(x: trailingContentOffsetX, y: contentOffset.y), animated: animated)
    }
    
    func scrollViewToVisible(_ view: UIView, animated: Bool = false) {
        scrollRectToVisible(convert(view.bounds, from: view), animated: true)
    }
    
    var isOnTop: Bool {
        contentOffset.y <= -adjustedContentInset.top
    }
    
    var isOnBottom: Bool {
        contentOffset.y >= bottomContentOffsetY
    }
    
}
