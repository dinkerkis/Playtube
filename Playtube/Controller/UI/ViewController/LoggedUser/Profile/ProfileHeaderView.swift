//
//  ProfileHeaderView.swift
//  Playtube
//
//  Created by iMac on 22/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import SDWebImage

protocol ProfileHeaderViewDelegate {
    func editButtonAction(_ sender: UIButton)
}

class ProfileHeaderView: UIView {
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var verifyIcon: UIImageView!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var videosLabel: UILabel!
    @IBOutlet var tabsView: TabsView!
    
    var profileTabArray = ["Videos", "Shorts", "PlayLists", "Activities", "About"]
    var selectedIndex = 0
    var delegate: ProfileHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.initialConfig()
    }
    
    
    
    // Edit Button Action
    @IBAction func editButtonAction(_ sender: UIButton) {
        self.delegate?.editButtonAction(sender)
        //        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    func initialConfig() {
        Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        self.setupTabs()
    }
    
    func setData() {
        self.userNameLabel.text = AppInstance.instance.userProfile?.data?.username ?? ""
        let coverImage = URL(string: AppInstance.instance.userProfile?.data?.cover ?? "")
        self.coverImage.sd_setImage(with: coverImage , placeholderImage:R.image.maxresdefault())
        let profileImage = URL(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
        self.avatarImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        switch AppInstance.instance.userProfile?.data?.subscribe_count {
        case .integer(let value):
            self.subscribersLabel.text = "\(value)"
        case .string(let value):
            self.subscribersLabel.text = "\(value)"
        default:
            break
        }
        self.videosLabel.text = "\(AppInstance.instance.userProfile?.data?.video_mon ?? 0)"
    }
    
    func setDataOtherUser(owner: Owner) {
        self.userNameLabel.text = owner.name ?? ""
        self.verifyIcon.isHidden = owner.verified == 0
        let coverImage = URL(string: owner.cover ?? "")
        self.coverImage.sd_setImage(with: coverImage , placeholderImage:R.image.maxresdefault())
        let profileImage = URL(string: owner.avatar ?? "")
        self.avatarImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        switch owner.subscribe_count {
        case .integer(let value):
            self.subscribersLabel.text = "\(value)"
        case .string(let value):
            self.subscribersLabel.text = "\(value)"
        default:
            break
        }
    }
    
    
    func setupTabs() {
        // Add Tabs (Set 'icon'to nil if you don't want to have icons)
        for i in profileTabArray {
            tabsView.tabs.append(.init(title: i))
        }
        
        // Set TabMode to '.fixed' for stretched tabs in full width of screen or '.scrollable' for scrolling to see all tabs
        tabsView.tabMode = .scrollable
        
        // TabView Customization
        tabsView.titleColor = UIColor(named: "Primary_UI_Primary")!
        tabsView.indicatorColor = UIColor(named: "Primary_UI_Primary")!
        tabsView.titleFont = UIFont(name: "TTCommons-Medium", size: 18.0) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        
        // Set the selected Tab when the app starts
        tabsView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    
}
