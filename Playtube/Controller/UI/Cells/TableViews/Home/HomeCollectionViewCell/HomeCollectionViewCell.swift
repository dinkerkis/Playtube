//
//  HomeCollectionViewCell.swift
//  Playtube
//
//  Created by iMac on 12/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import Toast_Swift

protocol HomeCollectionViewCellDelegate {
    func handleStockViewMoreButtonTap(sender: UIButton)
    func handleShortsViewMoreButtonTap(sender: UIButton)
    func handleTopViewMoreButtonTap(sender: UIButton)
    func handleLatestViewMoreButtonTap(sender: UIButton)
}

class HomeCollectionViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var featuredCollectionView: UICollectionView!
    @IBOutlet weak var featuredCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dotPageControl: UIPageControl!
    @IBOutlet weak var stockView: UIView!
    @IBOutlet weak var stockCollectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var shortsView: UIView!
    @IBOutlet weak var shortsCollectionView: UICollectionView!
    @IBOutlet weak var latestView: UIView!
    @IBOutlet weak var latestCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    var stockArray: [VideoDetail] = []
    var featuredArray: [VideoDetail] = []
    var topVideosArray: [VideoDetail] = []
    var latestVideosArray: [VideoDetail] = []
    var shortsVideosArray: [VideoDetail] = []
    var isLoading = false
    var parentContorller: HomeVC!
    weak var statusBarHiddenDelegate: StatusBarHiddenDelegate?
    var delegate: HomeCollectionViewCellDelegate?
    
    // MARK: - Initialize Functions

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initialConfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Selectors
        
    @IBAction func stockViewMoreButtonAction(_ sender: UIButton) {
        self.delegate?.handleStockViewMoreButtonTap(sender: sender)
    }
    
    @IBAction func shortsViewMoreButtonAction(_ sender: UIButton) {
        self.delegate?.handleShortsViewMoreButtonTap(sender: sender)
    }
    
    @IBAction func topViewMoreButtonAction(_ sender: UIButton) {
        self.delegate?.handleTopViewMoreButtonTap(sender: sender)
    }
    
    @IBAction func latestViewMoreButtonAction(_ sender: UIButton) {
        self.delegate?.handleLatestViewMoreButtonTap(sender: sender)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
    }
    
    // Register Cell
    func registerCell() {
        self.featuredCollectionView.delegate = self
        self.featuredCollectionView.dataSource = self
        self.featuredCollectionViewHeight.constant = (UIScreen.main.bounds.width * 290) / 360
        self.featuredCollectionView.register(UINib(resource: R.nib.featuredCell), forCellWithReuseIdentifier: R.reuseIdentifier.featuredCell.identifier)
        
        self.stockCollectionView.delegate = self
        self.stockCollectionView.dataSource = self
        self.stockCollectionView.register(UINib(resource: R.nib.stockCell), forCellWithReuseIdentifier: R.reuseIdentifier.stockCell.identifier)
        
        self.topCollectionView.delegate = self
        self.topCollectionView.dataSource = self
        self.topCollectionView.register(UINib(resource: R.nib.stockCell), forCellWithReuseIdentifier: R.reuseIdentifier.stockCell.identifier)
        
        self.shortsCollectionView.delegate = self
        self.shortsCollectionView.dataSource = self
        self.shortsCollectionView.register(UINib(resource: R.nib.shortsCell), forCellWithReuseIdentifier: R.reuseIdentifier.shortsCell.identifier)
        
        self.latestCollectionView.delegate = self
        self.latestCollectionView.dataSource = self
        self.latestCollectionView.register(UINib(resource: R.nib.stockCell), forCellWithReuseIdentifier: R.reuseIdentifier.stockCell.identifier)
    }
    
    // Setup UI
    func setupUI() {
        if isLoading {
            self.stockView.isHidden = false
            self.shortsView.isHidden = false
            self.topView.isHidden = false
            self.latestView.isHidden = false
        } else {
            self.stockView.isHidden = self.stockArray.count == 0
            self.shortsView.isHidden = self.shortsVideosArray.count == 0
            self.topView.isHidden = self.topVideosArray.count == 0
            self.latestView.isHidden = self.latestVideosArray.count == 0
            self.dotPageControl.numberOfPages = self.featuredArray.count
        }        
    }
    
    // Reload Data
    func reloadData() {
        self.featuredCollectionView.reloadData()
        self.stockCollectionView.reloadData()
        self.topCollectionView.reloadData()
        self.shortsCollectionView.reloadData()
        self.latestCollectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.featuredCollectionView {
            let xPoint = scrollView.contentOffset.x + scrollView.frame.width / 2
            let yPoint = scrollView.frame.height / 2
            let center = CGPoint(x: xPoint, y: yPoint)
            if let ip = self.featuredCollectionView.indexPathForItem(at: center) {
                self.dotPageControl.currentPage = ip.row
            }
        }
    }
    
}

// MARK: Collection View Setup
extension HomeCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading {
            return 10
        } else {
            switch collectionView {
            case self.featuredCollectionView:
                return self.featuredArray.count
            case self.stockCollectionView:
                return self.stockArray.count
            case self.topCollectionView:
                return self.topVideosArray.count
            case self.shortsCollectionView:
                return self.shortsVideosArray.count
            case self.latestCollectionView:
                return self.latestVideosArray.count
            default:
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.featuredCollectionView:
            if self.isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as! FeaturedCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as! FeaturedCell
                let object = self.featuredArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        case self.stockCollectionView:
            if self.isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCell", for: indexPath) as! StockCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCell", for: indexPath) as! StockCell
                let object = self.stockArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        case self.topCollectionView:
            if self.isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCell", for: indexPath) as! StockCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCell", for: indexPath) as! StockCell
                let object = self.topVideosArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        case self.shortsCollectionView:
            if self.isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShortsCell", for: indexPath) as! ShortsCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShortsCell", for: indexPath) as! ShortsCell
                let object = self.shortsVideosArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        case self.latestCollectionView:
            if self.isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCell", for: indexPath) as! StockCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCell", for: indexPath) as! StockCell
                let object = self.latestVideosArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoading {
            return
        } else {
            switch collectionView {
            case self.featuredCollectionView:
                AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
                let videoObject = self.featuredArray[indexPath.row]
                let newVC = self.parentContorller.tabBarController as! TabbarController
                newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            case self.stockCollectionView:
                let videoObject = self.stockArray[indexPath.row]
                AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
                let newVC = self.parentContorller.tabBarController as! TabbarController
                newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            case self.topCollectionView:
                let videoObject = self.topVideosArray[indexPath.row]
                AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
                let newVC = self.parentContorller.tabBarController as! TabbarController
                newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            case self.shortsCollectionView:
                let newVC = R.storyboard.loggedUser.shortsVC()
                newVC?.isFromTabbar = false
                newVC?.currentIndexPath = indexPath
                newVC?.shortsVideosArray = self.shortsVideosArray
                self.parentContorller.tabBarController?.navigationController?.pushViewController(newVC!, animated: true)
            case self.latestCollectionView:
                let videoObject = self.latestVideosArray[indexPath.row]
                AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
                let newVC = self.parentContorller.tabBarController as! TabbarController
                newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            default:
                break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case self.featuredCollectionView:
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        case self.stockCollectionView, self.topCollectionView, latestCollectionView:
            return CGSize(width: 248, height: 202)
        case self.shortsCollectionView:
            return CGSize(width: 154, height: 250)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case self.featuredCollectionView:
            return 0.0
        case self.stockCollectionView, self.topCollectionView, self.latestCollectionView:
            return 12
        case self.shortsCollectionView:
            return 8
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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

// MARK: StatusBarHiddenDelegate
extension HomeCollectionViewCell: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.statusBarHiddenDelegate?.handleUpdate(isStatusBarHidden: isStatusBarHidden)
    }
    
}
