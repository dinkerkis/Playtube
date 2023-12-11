//
//  ProfileShortsVC.swift
//  Playtube
//
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import Refreshable
import UIView_Shimmer

class shortsProfileCell : UITableViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var isVerifiediamge: UIImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var shortsDefaultImg: RoundImage!
    
    var object: VideoDetail?
    var index: Int? = 0
    var delegate: ShowPresentControllerDelegate?
    
    var shimmeringAnimatedItems: [UIView] {
        [
            thumbnailImage,
            titleLabel,
            usernameLabel,
            isVerifiediamge,
            viewsLabel,
            moreBtn,
            shortsDefaultImg
        ]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // Option Button Action
    @IBAction func optionButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.popups.videoOptionPopupVC()
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        newVC?.object = self.object
        obj_appDelegate.window?.rootViewController?.present(newVC!, animated: true)
    }
    
    func bind(_ object: VideoDetail){
        self.object = object
        
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        self.viewsLabel.text = "| \(object.views?.roundedWithAbbreviations ?? "") Views | \(object.time_ago ?? "") |"
        self.usernameLabel.text = object.owner?.username
        //            if object.owner!.verified == 1{
        self.isVerifiediamge.isHidden = true
        //            }else{
        //                self.isVerifiedImage.isHidden = false
        //            }
        let thumbnailImage = URL(string: object.thumbnail ?? "")
        self.thumbnailImage.sd_setShowActivityIndicatorView(true)
        self.thumbnailImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbnailImage.sd_setImage(with: thumbnailImage , placeholderImage:R.image.maxresdefault())
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension shortsProfileCell: UIViewControllerTransitioningDelegate {    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}


protocol ProfileShortsVCDelegate: AnyObject {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
}

class ProfileShortsVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: ProfileShortsVCDelegate?
    @IBOutlet weak var noDataStack: UIStackView!
    
    var shortsVideosArray: [VideoDetail] = []
    private var isLoading = true {
        didSet {
//            DispatchQueue.main.async { [self] in
////                self.tableView.reloadData()
//            }
        }
    }
    
    var heightTableView:((_ count: Int, _ identifire: Int) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        isLoading = true
        self.tableView.setLoadMoreEnable(true)
    }
    func reloadTableView() {
        DispatchQueue.main.async {
            if !self.shortsVideosArray.isEmpty {
                self.noDataStack.isHidden = true
                self.tableView.isHidden = false
            }else{
                self.noDataStack.isHidden = false
                self.tableView.isHidden = true
            }
            self.isLoading = false
            self.tableView.reloadData()
        }
    }
    
    static func profileShortsVC() -> ProfileShortsVC {
        let newVC = R.storyboard.loggedUser.profileShortsVC()
        return newVC!
    }
}

extension ProfileShortsVC: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: self.tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.shortsVideosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shortsProfileCell", for: indexPath) as! shortsProfileCell
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "shortsProfileCell", for: indexPath) as! shortsProfileCell
            let object = self.shortsVideosArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}
