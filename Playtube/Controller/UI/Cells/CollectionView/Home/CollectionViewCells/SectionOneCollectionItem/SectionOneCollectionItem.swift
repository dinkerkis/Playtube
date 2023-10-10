
import UIKit

class SectionOneCollectionItem: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse()
    {
        profileImage.image = nil
        backgroundImage.image = nil
        titleLabel.text = nil
        usernameLabel.text = nil
    }
    
    func bind(_ object:Home.Featured){
        
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        self.usernameLabel.text = object.owner?.username?.htmlAttributedString ?? ""
        let thumbnailURL = URL(string: object.thumbnail ?? "")
        
        self.backgroundImage.sd_setShowActivityIndicatorView(true)
        self.backgroundImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.backgroundImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.maxresdefault())
        }
        
        
        let profilelURL = URL(string: object.owner?.avatar ?? "")
        self.profileImage.sd_setShowActivityIndicatorView(true)
        self.profileImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.profileImage.sd_setImage(with: profilelURL , placeholderImage:R.image.maxresdefault())
        }
        
        
    }
    
    func data(_ index :[String:Any]){
        self.usernameLabel.text = ""
       
        if let title = index["title"] as? String{
            self.titleLabel.text = title.htmlAttributedString ?? ""
        }
        if let backImage = index["thumbnail"] as? String{
            let url = URL(string: backImage)
            self.backgroundImage.sd_setImage(with: url , placeholderImage:R.image.maxresdefault())
        }
    }
}

