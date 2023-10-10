

import UIKit

class ChatLeftTableItem: UITableViewCell {

    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var userImage: RoundImage!
    
    var userData: ChatModel.User?
    var userImg : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(_ object:UserChatModel.Message){
        self.messageTextLabel.text = object.text?.htmlAttributedString ?? "" + "\n\n\(object.textTime ?? "")"
        let imageURl = self.userData?.avatar == nil ? userImg : ""
        
        let url = URL(string: imageURl ?? "")
        
        self.userImage.sd_setShowActivityIndicatorView(true)
        self.userImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.userImage.sd_setImage(with: url , placeholderImage:R.image.maxresdefault())
        }
        
    }
}
