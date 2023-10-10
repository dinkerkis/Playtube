import UIKit
import Toast_Swift
import JGProgressHUD
import SwiftEventBus
import ContactsUI
import Async
import SDWebImage
import AVKit
import UserNotifications
import MediaPlayer
import PlaytubeSDK

class BaseVC: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var hud : JGProgressHUD?
    
    //    private var noInternetVC: NoInternetDialogVC!
    var userId:String? = nil
    var sessionId:String? = nil
    var contactNameArray = [String]()
    var contactNumberArray = [String]()
    var deviceID:String? = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.dismissKeyboard()
        self.deviceID = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
        //        noInternetVC = R.storyboard.main.noInternetDialogVC()
        //
        //        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            //            self.CheckForUserCAll()
            //            log.verbose("Internet connected!")
            //            self.noInternetVC.dismiss(animated: true, completion: nil)
            
        }
        
        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            //            log.verbose("Internet dis connected!")
            //                self.present(self.noInternetVC, animated: true, completion: nil)
            
        } 
    }
    
    func loadImageAsync(img : UIImageView, imageName: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            img.sd_setShowActivityIndicatorView(true)
            img.sd_setIndicatorStyle(.medium)
            img.sd_setImage(with: URL(string: imageName) , placeholderImage:R.image.maxresdefault())
        }
    }
    
    func showLoaderAndHideButton(btn:UIButton,loader:UIActivityIndicatorView)
    {
        btn.isHidden = true
        loader.isHidden = false
        loader.startAnimating()
    }
    
    func showLoaderOnly(loader:UIActivityIndicatorView)
    {
        loader.isHidden = false
        loader.startAnimating()
    }
    
    func dismissLoaderOnly(loader:UIActivityIndicatorView)
    {
        loader.stopAnimating()
    }
    
    func dismissLoaderAndHideButton(btn:UIButton,loader:UIActivityIndicatorView)
    {
        btn.isHidden = false
        loader.stopAnimating()
    }
    
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
        
    }
    
    func dismissProgressDialog(completionBlock: @escaping () ->()) {
        hud?.dismiss()
        completionBlock()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.tabBarController?.addSubviewToLastTabItem()
    }
    
}
