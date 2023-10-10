

import UIKit
import WebKit
class NotificationTableItem: UITableViewCell {
    
    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func bind(_ object:NotificationsModel.Notification){
        self.usernameLabel.text = object.userData?.username ?? ""
        self.titleLabel.text = object.title ?? ""
        self.timeLabel.text = object.time ?? ""
//        self.webView.loadHTMLString(object.icon ?? "", baseURL: nil)
//        self.userImg.image = #imageLiteral(resourceName: "loginPerson")
        
        let profileImage = URL(string: object.userData?.avatar ?? "")
        self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        
        var rect: CGRect = usernameLabel.frame //get frame of label
        rect.size = (usernameLabel.text?.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: usernameLabel.font.fontName , size: usernameLabel.font.pointSize)!]))! //Calculate as per label font
       // labelWidth.constant = rect.width + 24 // set width to Constraint outlet
        
    }
    
}
