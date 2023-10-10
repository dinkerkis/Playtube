import UIKit
import SDWebImage

class ArticleSectionOneTableItem: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var disLikeCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblSubscribers: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblDescSecond: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgDislike: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func bind(_ object: Article) {
        self.titleLabel.text = object.title?.htmlAttributedString
        self.lblDescSecond.text = object.title?.htmlAttributedString
        self.lblViews.text = "\(object.views ?? "") Views | \(object.shared ?? 0) Shares | \(object.comments_count ?? 0) Comments | \(object.text_time ?? "")"
        self.likeCountLabel.text = "\(object.likes ?? 0)"
        self.disLikeCountLabel.text = "\(object.dislikes ?? 0)"
        let thumbnailImage = URL(string: object.image ?? "")
        self.thumbnailImage.sd_setShowActivityIndicatorView(true)
        self.thumbnailImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbnailImage.sd_setImage(with: thumbnailImage, placeholderImage: R.image.maxresdefault())
        }
        self.lblUsername.text = object.user_data?.username ?? ""
        switch object.user_data?.subscribe_count {
        case .integer(let value):
            self.lblSubscribers.text = "\(value) Subscribers"
        case .string(let value):
            self.lblSubscribers.text = "\(value) Subscribers"
        default:
            break
        }
        let profileImage = URL(string: object.user_data?.avatar ?? "")
        self.imgProfile.sd_setShowActivityIndicatorView(true)
        self.imgProfile.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.imgProfile.sd_setImage(with: profileImage, placeholderImage: R.image.maxresdefault())
        }
        if object.likes == 0 && object.dislikes == 0 {
            self.imgLike.image = UIImage(named: "like_gray")
            self.imgDislike.image = UIImage(named: "dislike_gray")
        } else {
            if object.liked == 1 {
                self.imgLike.image = UIImage(named: "like_blue-1")
                self.imgDislike.image = UIImage(named: "dislike_gray")
            } else if (object.disliked == 1) {
                self.imgLike.image = UIImage(named: "like_gray")
                self.imgDislike.image = UIImage(named: "dislike_blue-1")
            } else {
                self.imgLike.image = UIImage(named: "like_gray")
                self.imgDislike.image = UIImage(named: "dislike_gray")
            }
        }
    }
    
}
