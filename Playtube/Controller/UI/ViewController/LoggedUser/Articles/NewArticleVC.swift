//
//  NewArticleVC.swift
//  Playtube
//
//  Created by iMac on 31/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import GoogleMobileAds
import Toast_Swift

class NewArticleVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Properties
    
    var categories: [CategoryStruct] = []
    var selectedIndex = 0
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    private var articlesArray: [Article] = []
    private var popularArticlesArray: [Article] = []
    private var filterArticleArray: [Article] = []
    private var isLoading = true {
        didSet {
            tableView.reloadData()
        }
    }
    var categoryId = ""
    var isSearch = false
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Create Article Button Action
    @IBAction func createArticleButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.loggedUser.webViewVC()
        vc!.boolStatus = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    func setupUI() {
        self.textField.delegate = self
        self.registerCollectionCell()
        self.registerTableViewCell()
        let data = AppInstance.instance.categories.sorted { dic1, dic2 in
            return dic1.value < dic2.value
        }
        for (key, value) in  data {
            let category = CategoryStruct(cat_Name: value, cate_id: key)
            self.categories.append(category)
        }
        self.collectionView.reloadData()
        isLoading = true
        self.categoryId = self.categories[0].cate_id
        self.fetchArticles(cate_id: self.categoryId, url: API.Articles_Methods.FETCH_ARTICLES_API)
        self.fetchArticles(cate_id: "", url: API.Articles_Methods.MOST_POPULAR_ARTICLES_API, isPopular: true)
        self.tableView.addPullRefresh { [weak self] in
            if (self?.isSearch ?? false) {
                self?.tableView.stopPullRefreshEver()
            } else {
                self?.isLoading = true
                self?.fetchArticles(cate_id: self?.categoryId ?? "", url: API.Articles_Methods.FETCH_ARTICLES_API)
                self?.fetchArticles(cate_id: "", url: API.Articles_Methods.MOST_POPULAR_ARTICLES_API, isPopular: true)
            }
        }
    }
    
    func registerCollectionCell() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.profileTabOptionCell), forCellWithReuseIdentifier: R.nib.profileTabOptionCell.identifier)
    }
    
    func registerTableViewCell() {
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        self.tableView.register(UINib(resource: R.nib.articlesTableViewCell), forCellReuseIdentifier: R.reuseIdentifier.articlesTableViewCell.identifier)
        self.tableView.register(UINib(resource: R.nib.articleListCell), forCellReuseIdentifier: R.reuseIdentifier.articleListCell.identifier)
    }
    
}

// MARK: - Extensions

// MARK: API Services
extension NewArticleVC {
    
    private func fetchArticles(cate_id: String, url: String, isPopular: Bool = false) {
        //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        Async.background {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            ArticlesManager.instance.getTrendingData(url: url, cat_id: cate_id, User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            if isPopular {
                                self.popularArticlesArray = success?.data ?? []
                            } else {
                                self.articlesArray = success?.data ?? []
                            }
                            self.articlesArray = self.articlesArray.filter { article in
                                !(self.popularArticlesArray.contains { popularArticle in
                                    return article.id == popularArticle.id
                                })
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                            }
                        }
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
            })
        }
    }
    
}

// MARK: TableView SetUp
extension NewArticleVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearch {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            if isLoading {
                return 10
            } else {
                return self.filterArticleArray.count
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            if isLoading {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleListCell.identifier) as! ArticleListCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleListCell.identifier) as! ArticleListCell
                let object = self.filterArticleArray[indexPath.row]
                cell.vc = self
                cell.bind(object)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesTableViewCell.identifier) as! ArticlesTableViewCell
            cell.articlesArray = indexPath.section != 0 ? self.popularArticlesArray : self.articlesArray
            cell.isLoading = self.isLoading
            cell.parentVC = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearch {
            if isLoading {
                return 120.0
            } else {
                return self.filterArticleArray.count == 0 ? 0 : 120.0
            }
        } else {
            if isLoading {
                return 329.0
            } else {
                if indexPath.section == 0 {
                    return self.articlesArray.count == 0 ? 0 : 329.0
                } else {
                    return self.popularArticlesArray.count == 0 ? 0 : 329.0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearch {
            return nil
        } else {
            if section == 1 {
                let headerView = ArticleHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 48))
                headerView.titleLabel.text = "Most Popular"
                return headerView
            } else {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearch {
            return 0
        } else {
            if section == 1 {
                return 48.0
            } else {
                return 0.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: articleCatDelegate Methods
extension NewArticleVC: ArticleCategoryDelegate {
    
    func articalCat(id: String, url: String) {
        self.articlesArray.removeAll()
        self.tableView.reloadData()
        print(id, url)
        self.isLoading = true
        self.fetchArticles(cate_id: id, url: url)
    }
    
}

// MARK: Collection View SetUp
extension NewArticleVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profileTabOptionCell.identifier, for: indexPath) as! ProfileTabOptionCell
        cell.titleLabel.text = self.categories[indexPath.row].cat_Name.htmlAttributedString
        cell.borderHeight.constant = 4.0
        cell.bottomBorder.cornerRadiusV = 2.0
        if self.selectedIndex == indexPath.row {
            cell.titleLabel.font = UIFont(name: "TTCommons-DemiBold", size: 18.0)
            cell.titleLabel.textColor = UIColor(named: "Primary_UI_Primary")
            cell.bottomBorder.backgroundColor = UIColor(named: "Primary_UI_Primary")
        } else {
            cell.titleLabel.font = UIFont(name: "TTCommons-Medium", size: 18.0)
            cell.titleLabel.textColor = UIColor(named: "Label_Colors_Secondary")
            cell.bottomBorder.backgroundColor = UIColor(named: "Primary_UI_Tertiary")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
        isLoading = true
        self.categoryId = self.categories[indexPath.row].cate_id
        self.articalCat(id: self.categoryId, url: API.Articles_Methods.FETCH_ARTICLES_API)
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout Methods
extension NewArticleVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = self.categories[indexPath.row].cat_Name.htmlAttributedString ?? ""
        if selectedIndex == indexPath.row {
            return CGSize(width: getWidthFromItem(title: text, font: setCustomFont(size: 18.0, fontName: "TTCommons-DemiBold")).width + 25, height: 40)
        } else {
            return CGSize(width: getWidthFromItem(title: text, font: setCustomFont(size: 18.0, fontName: "TTCommons-Medium")).width + 25, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    // Get Width From String
    func getWidthFromItem(title: String, font: UIFont) -> CGSize {
        let itemSize = title.size(withAttributes: [
            NSAttributedString.Key.font: font
        ])
        return itemSize
    }
    
    // Set Custom Font
    func setCustomFont(size: CGFloat, fontName: String) -> UIFont {
        return UIFont.init(name: fontName, size: size)!
    }
    
}

// MARK: UITextFieldDelegate Methods
extension NewArticleVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == self.textField {
            if textField.text == "" {
                self.isSearch = false
            } else {
                self.filterArticleArray = self.popularArticlesArray.filter({ model in
                    return model.title?.localizedCaseInsensitiveContains(textField.text ?? "") ?? false
                })
                self.isSearch = true
            }
            self.tableView.reloadData()
        }
    }
    
}
