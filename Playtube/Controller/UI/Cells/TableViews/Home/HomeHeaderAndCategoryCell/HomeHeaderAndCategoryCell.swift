//
//  HomeHeaderAndCategoryCell.swift
//  Playtube
//
//  Created by iMac on 12/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol HomeHeaderAndCategoryCellDelegate {
    func handleChatButtonTap(sender: UIButton)
    func handleSearchButtonTap(sender: UIButton)
    func handleNotificationButtonTap(sender: UIButton)
    func handleProfileButtonTap(sender: UIButton)
    func handleCategoryTap(category: CategoryStruct)
}

class HomeHeaderAndCategoryCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var selectedCategoryIndex = 0
    var categories: [CategoryStruct] = []
    var delegate: HomeHeaderAndCategoryCellDelegate?
    
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
    
    // Chat Button Action
    @IBAction func chatButtonAction(_ sender: UIButton) {
        self.delegate?.handleChatButtonTap(sender: sender)        
    }
    
    // Search Button Action
    @IBAction func searchButtonAction(_ sender: UIButton) {
        self.delegate?.handleSearchButtonTap(sender: sender)
    }
    
    // Notification Button Action
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        self.delegate?.handleNotificationButtonTap(sender: sender)
    }
    
    // Profile Button Action
    @IBAction func profileButtonAction(_ sender: UIButton) {
        self.delegate?.handleProfileButtonTap(sender: sender)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupUI()
        self.registerCell()
    }
    
    // Register Cell
    func registerCell() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.categoryCell), forCellWithReuseIdentifier: R.reuseIdentifier.categoryCell.identifier)
    }
    
    // Setup UI
    func setupUI() {
        self.notificationButton.isHidden = AppInstance.instance.userType == 0
        self.profileButton.isHidden = AppInstance.instance.userType == 0
        self.chatButton.isHidden = AppInstance.instance.userType == 0
    }
    
}

// MARK: Collection View Setup
extension HomeHeaderAndCategoryCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.categoryLabel.isHidden = false
        if indexPath.row == 0 {
            cell.categoryLabel.text = "For You"
        } else {
            cell.categoryLabel.text = self.categories[indexPath.row - 1].cat_Name
        }
        if indexPath.row == self.selectedCategoryIndex {
            cell.backView.layer.borderWidth = 0
            cell.backView.backgroundColor = UIColor(named: "Primary_UI_Primary")
            cell.categoryLabel.textColor = UIColor(named: "Primary_UI_Tertiary")
        } else {
            cell.backView.layer.borderWidth = 1
            cell.backView.layer.borderColor = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 0.7).cgColor
            cell.backView.backgroundColor = .white//UIColor(named: "Fill_Colors_Tertiary")
            cell.categoryLabel.textColor = .black//UIColor(named: "Label_Colors_Secondary")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category: CategoryStruct?
        if indexPath.row == 0 {
            category = CategoryStruct(cat_Name: "For You", cate_id: "0000")
        } else {
            category = self.categories[indexPath.row - 1]
        }
        if let category = category {
            self.delegate?.handleCategoryTap(category: category)
        }
        self.selectedCategoryIndex = indexPath.row
        self.collectionView.scrollToItem(at: IndexPath(item: indexPath.row, section: 0), at: .centeredHorizontally, animated: true)
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: getWidthFromItem(title: "For You", font: setCustomFont(size: 16.0, fontName: "TTCommons-Medium")).width + 29, height: 32)
        } else {
            return CGSize(width: getWidthFromItem(title: self.categories[indexPath.row - 1].cat_Name, font: setCustomFont(size: 16.0, fontName: "TTCommons-Medium")).width + 29, height: 32)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
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
