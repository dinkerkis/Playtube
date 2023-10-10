
import UIKit

class ChatTableItem: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func bind(_ object:ChatModel.Datum){
        if (object.user!.firstName?.isEmpty)! && (object.user!.lastName?.isEmpty)!{
            self.usernameLabel.text = object.user!.username ?? ""
        }else{
            self.usernameLabel.text = object.user!.firstName ?? "" + object.user!.lastName!
        }
        self.lastMessageLabel.text = object.getLastMessage!.text ?? ""
        self.timeLabel.text = object.getLastMessage!.textTime ?? ""
        
        let profileImage = URL(string: object.user?.avatar ?? "")
        self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        
    }
}
