import UIKit
import DropDown
import PlaytubeSDK
import UIView_Shimmer

class PlayerNextTableItem: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var videoTypeImage: UIImageView!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var verifiedBadge: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            thumbnailImage,
            videoTypeImage,
            timeView,
            titleLabel,
            optionButton,
            usernameLabel,
            verifiedBadge,
            viewsLabel,
            timeLabel            
        ]
    }
    var object: VideoDetail?
    
    // MARK: - Initialize Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - Selectors
    
    // Option Button Action
    @IBAction func optionButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.popups.videoOptionPopupVC()
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        newVC?.object = self.object
        obj_appDelegate.window?.rootViewController?.present(newVC!, animated: true)
    }
    
    func bind(_ object: VideoDetail) {
        self.object = object
        self.titleLabel.text = object.title!.htmlAttributedString ?? ""
        self.viewsLabel.text = "\(object.views!.roundedWithAbbreviations) Views"
        self.usernameLabel.text = object.owner!.username!.htmlAttributedString ?? ""
        self.timeLabel.text = object.duration ?? ""
        self.verifiedBadge.isHidden = (object.owner?.verified ?? 0) != 1
        if object.source == "YouTube" || object.source == "youtu" || object.video_type == "VideoObject/youtube" {
            self.videoTypeImage.image = UIImage(named: "square-youtube")
        } else if object.source == "Vimeo" {
            self.videoTypeImage.image = UIImage(named: "vimeo")
        } else if object.source == "Dailymotion" {
            self.videoTypeImage.image = UIImage(named: "dailymotion")
        } else {
            if object.is_short == 1 {
                self.videoTypeImage.image = UIImage(named: "square-video")
            } else {
                self.videoTypeImage.image = nil
            }
        }
        let thumbnailImage = URL(string: object.thumbnail ?? "")
        self.thumbnailImage.sd_setShowActivityIndicatorView(true)
        self.thumbnailImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbnailImage.sd_setImage(with: thumbnailImage , placeholderImage:R.image.maxresdefault())
        }
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension PlayerNextTableItem: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
