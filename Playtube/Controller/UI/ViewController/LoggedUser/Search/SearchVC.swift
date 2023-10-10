//
//  SearchVC.swift
//  Playtube
//
//  Created by Ubaid Javaid on 6/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Toast_Swift
import PlaytubeSDK
import Async

class SearchVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchClearButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    
    // MARK: - Properties
    
    var isSearch = false {
        didSet {
            self.filterButton.isHidden = !self.isSearch
        }
    }
    var searchCategoryArr: [String] = [
        "Music",
        "Party",
        "Nature",
        "Snow",
        "Entertainment",
        "Holidays",
        "Covid19",
        "Comedy",
        "Politics",
        "Suspense"
    ]
    var recentSearchArr: [String] = []
    var searchListArr: [String] = []
    var searchVideosArray = [VideoDetail]()
    var isLoading = false
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
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Search Clear Button Action
    @IBAction func searchClearButtonAction(_ sender: UIButton) {
        self.searchTextField.text = ""
        self.searchClearButton.isHidden = true
        self.isSearch = false
        self.tableView.reloadData()
    }
    
    // Filter Button Action
    @IBAction func filterButtonAction(sender: UIButton) {
        let newVC = R.storyboard.loggedUser.searchFilterVC()
        newVC?.delegate = self
        newVC?.modalPresentationStyle = .overFullScreen
        newVC?.modalTransitionStyle = .crossDissolve
        self.present(newVC!, animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.searchBarSetup()
        self.registerCell()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.searchCategoryCell), forCellReuseIdentifier: R.reuseIdentifier.searchCategoryCell.identifier)
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
    }
    
    // Search Bar Setup
    func searchBarSetup() {
        self.searchTextField.delegate = self
        self.searchClearButton.isHidden = true
        self.isSearch = false
        self.recentSearchArr = []
        self.searchListArr = []
        var tempSearchArr = ((UserDefaults.standard.value(forKey: "RecentSearchString") as? String) ?? "").split(separator: ",")
        for search in tempSearchArr {
            self.recentSearchArr.append(String(search))
        }
        self.searchListArr.append(contentsOf: self.recentSearchArr)
        self.searchListArr.append(contentsOf: self.searchCategoryArr)
        self.searchListArr = self.searchListArr.unique()
        self.tableView.reloadData()
    }
    
    // Add Search Text In Recent Search
    func addSearchTextInRecentSearch(searchText: String) {
        var recentSearchString = searchText
        self.recentSearchArr = []
        self.searchListArr = []
        recentSearchString = recentSearchString + "," + ((UserDefaults.standard.value(forKey: "RecentSearchString") as? String) ?? "")
        UserDefaults.standard.setValue(recentSearchString, forKey: "RecentSearchString")
        var tempSearchArr = (UserDefaults.standard.value(forKey: "RecentSearchString") as! String).split(separator: ",")
        for search in tempSearchArr {
            self.recentSearchArr.append(String(search))
        }
        self.searchListArr.append(contentsOf: self.recentSearchArr)
        self.searchListArr.append(contentsOf: self.searchCategoryArr)
        self.searchListArr = self.searchListArr.unique()
        let updatedString = self.recentSearchArr.joined(separator: ",")
        UserDefaults.standard.setValue(updatedString, forKey: "RecentSearchString")
    }

}

// MARK: - Extensions

// MARK: Api Call
extension SearchVC {
    
    private func searchVideos(searchText: String, userID: Int, sessionID: String, filterParam: String) {
        self.isLoading = true
        self.searchVideosArray = []
        self.tableView.reloadData()
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                SearchManager.instance.searchVideo(User_id: userID, Session_Token: sessionID, SearchText: searchText, filterParam: filterParam) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.isLoading = false
                            self.searchVideosArray = success?.data ?? []
                            if self.searchVideosArray.count == 0 {
                                self.searchTextField.text = ""
                                self.searchClearButton.isHidden = true
                                self.isSearch = false
                            }
                            self.addSearchTextInRecentSearch(searchText: searchText)
                            self.tableView.reloadData()
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    } else {
                        Async.main {
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
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            if isLoading {
                return 10
            } else {
                return self.searchVideosArray.count
            }
        } else {
            return self.searchListArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            if isLoading {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell") as! TrendingCell
                let object = self.searchVideosArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchCategoryCell.identifier) as! SearchCategoryCell
            cell.titleLabel?.text = self.searchListArr[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearch {
            if !isLoading {
                let videoObject = self.searchVideosArray[indexPath.row]
                AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
                let newVC = self.tabBarController as! TabbarController
                newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            }            
        } else {
            self.isSearch = true
            self.searchClearButton.isHidden = false
            self.searchTextField.text = searchListArr[indexPath.row]
            let userId = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            self.searchVideos(searchText: searchListArr[indexPath.row], userID: userId, sessionID: sessionID, filterParam: "")
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isSearch {
            cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        }
    }
    
}

// MARK: UITextFieldDelegate
extension SearchVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchText = searchTextField.text ?? ""
        let converted = searchText.replacingOccurrences(of: " ", with: "")
        let userId = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        self.searchVideos(searchText: converted, userID: userId, sessionID: sessionID, filterParam: "")
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == searchTextField {
            if textField.text == "" {
                self.searchClearButton.isHidden = true
                self.isSearch = false
                self.tableView.reloadData()
            } else {
                self.searchClearButton.isHidden = false
                self.isSearch = true
            }
        }
    }
    
}

// MARK: SearchFilterVCDelegate
extension SearchVC: SearchFilterVCDelegate {
    
    func handleSearchFilter(searchData: SearchFilterModel) {
        let searchText = searchTextField.text ?? ""
        let converted = searchText.replacingOccurrences(of: " ", with: "")
        let userId = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        self.searchVideos(searchText:converted, userID: userId, sessionID: sessionID, filterParam: (searchData.parameter ?? ""))
    }
    
}

// MARK: StatusBarHiddenDelegate
extension SearchVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }    
    
}

// MARK: Overriden Properties
extension SearchVC {
    
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

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
