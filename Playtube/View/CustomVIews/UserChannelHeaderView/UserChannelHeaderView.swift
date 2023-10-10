//
//  UserChannelHeaderView.swift
//  Playtube
//
//  Created by iMac on 25/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol UserChannelHeaderViewDelegate {
    func handleDidSelectItemAt(indexPath: IndexPath)
    func handleSubscribeButtonTap(sender: UIButton)
}

class UserChannelHeaderView: UIView {

    // MARK: - IBOutlets

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var videosLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    
    var userChannleTabArray = ["Videos", "Shorts", "PlayLists", "Activities", "About"]
    var selectedIndex = 0
    var channelData: Owner?
    var delegate: UserChannelHeaderViewDelegate?
    
    // MARK: - Initialize Function

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Initial Code
        
        self.setInitialLayout()
    }
    
}

// MARK: - Layout Methods
extension UserChannelHeaderView {
    
    // MARK: - Selectors
    
    // Subscribe Button Action
    @IBAction func subscribeButtonAction(_ sender: UIButton) {
        self.delegate?.handleSubscribeButtonTap(sender: sender)
    }
    
    // MARK: - Helper Functions

    func setInitialLayout() {
        Bundle.main.loadNibNamed("UserChannelHeaderView", owner: self, options: nil)
        self.contentView.isOpaque = false
        addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.initialConfig()
    }
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
    }
    
    // Register Cell
    func registerCell() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.profileTabOptionCell), forCellWithReuseIdentifier: R.reuseIdentifier.profileTabOptionCell.identifier)
    }
    
    // Set Date
    func setData() {
        self.userNameLabel.text = self.channelData?.username ?? ""
        let coverImage = URL(string: self.channelData?.cover ?? "")
        self.coverImage.sd_setImage(with: coverImage , placeholderImage:R.image.maxresdefault())
        let profileImage = URL(string: self.channelData?.avatar ?? "")
        self.avatarImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        switch channelData?.subscribe_count {
        case .integer(let value):
            self.subscribersLabel.text = "\(value)"
        case .string(let value):
            self.subscribersLabel.text = "\(value)"
        default:
            break
        }
        self.videosLabel.text = "\(self.channelData?.video_mon ?? 0)"
        if self.channelData?.am_i_subscribed == 0 {
            self.subscribeButton.setTitle("+ Subscribe", for: .normal)
        } else {
            self.subscribeButton.setTitle("✓ Subscribed", for: .normal)
        }
    }

}

// MARK: - Extensions

// MARK: Collection View Setup
extension UserChannelHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userChannleTabArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profileTabOptionCell.identifier, for: indexPath) as! ProfileTabOptionCell
        cell.titleLabel.text = self.userChannleTabArray[indexPath.row]
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
        self.delegate?.handleDidSelectItemAt(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedIndex == indexPath.row {
            return CGSize(width: getWidthFromItem(title: self.userChannleTabArray[indexPath.row], font: setCustomFont(size: 18.0, fontName: "TTCommons-DemiBold")).width + 25, height: 48)
        } else {
            return CGSize(width: getWidthFromItem(title: self.userChannleTabArray[indexPath.row], font: setCustomFont(size: 18.0, fontName: "TTCommons-Medium")).width + 25, height: 48)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
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
