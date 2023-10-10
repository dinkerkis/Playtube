

import UIKit

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

class ChatRightTableItem: UITableViewCell {

    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var msgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //msgView.roundCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 14.0)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func bind(_ object:UserChatModel.Message){
        self.messageTextLabel.text = object.text ?? "" + "\n\n\(object.textTime ?? "")"
        
    }
    
}
