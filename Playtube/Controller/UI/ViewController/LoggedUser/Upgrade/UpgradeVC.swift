

import UIKit
import PlaytubeSDK
import Async
import Braintree

class UpgradeVC: BaseVC {
    
    
    //@IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var discoverLabel: UILabel!
    
    
    //    var payPalConfig = PayPalConfiguration() // default
    //    var environment:String = PayPalEnvironmentSandbox {
    //        willSet(newEnvironment) {
    //            if (newEnvironment != environment) {
    //                PayPalMobile.preconnect(withEnvironment: newEnvironment)
    //            }
    //        }
    //    }
    var braintree: BTAPIClient?
    var braintreeClient: BTAPIClient?
    
    private var upgardeArray = [[String:Any]]()
    var selectedindex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.collectionView.delegate = self
        //self.collectionView.dataSource = self
        
        let pro1 = [
            "main_image":"Shape-2",
            "price":"0",
            "pro_type": NSLocalizedString("Free Member", comment: "Free Member"),
            "upload_limit":NSLocalizedString("Upload unlimited videos", comment: "Upload unlimited videos"),
            "ads": NSLocalizedString("Videos ads will show up", comment: "Videos ads will show up"),
            "featured": NSLocalizedString("No Featured videos", comment: "No Featured videos"),
            "badge": NSLocalizedString("No Verified badge", comment: "No Verified badge"),
            "sell":"",
            "BtnColor":"#408BD8",
            "BtnType":"0"]
        let pro2 = ["main_image":"badge","price":"10","pro_type":"Pro Member","upload_limit": NSLocalizedString("Upload to 1GB", comment: "Upload to 1GB"),"ads": NSLocalizedString("No ads will show up", comment: "No ads will show up"),"featured": NSLocalizedString("Featured videos", comment: "Featured videos"),"badge": NSLocalizedString("Verified badge", comment: "Verified badge"),"sell": NSLocalizedString("Sell videos at any price", comment: "Sell videos at any price"),"BtnColor":"#73368D","BtnType":"1"]
        self.upgardeArray.append(pro1)
        self.upgardeArray.append(pro2)
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUpgrade(_ sender: Any) {
        self.startCheckout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = false
        //self.collectionView.reloadData()
        /*let yourBackImage = UIImage(named: "left-arrows")
         self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
         self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
         self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
         let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
         navigationController?.navigationBar.titleTextAttributes = textAttributes
         self.title = NSLocalizedString("Go Pro", comment: "Go Pro")
         self.discoverLabel.text = NSLocalizedString("Dicover more features with Playtube Pro Package", comment: "Dicover more features with Playtube Pro Package")*/
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = true
        
    }
    @IBAction func upgradeNowPressed(_ sender: Any) {
        //        startCheckout()
        
    }
    
    private func upgradeMemberShip(){
        if Connectivity.isConnectedToNetwork(){
            let sessionID = AppInstance.instance.sessionId ?? ""
            let userID = AppInstance.instance.userId ?? 0
            Async.background({
                UpgradeManager.instance.upgrade(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.message ?? "")")
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.errors?.error_text ?? "")
                                log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    func startCheckout() {
        let alert = UIAlertController(title: "payout", message: "select payment method", preferredStyle: .actionSheet)
        let banktransfer = UIAlertAction(title: "Bank Transfer", style: .default) { (action) in
            log.verbose("BankTransfer")
            let vc = R.storyboard.settings.bankTransferVC()
            self.navigationController?.pushViewController( vc!, animated: true)
        }
        let creditCard = UIAlertAction(title: "Credit Card", style: .default) { (action) in
            log.verbose("Credit Card")
        }
        let paypal =  UIAlertAction(title: "Paypal", style: .default) { (action) in
            self.paypal()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(banktransfer)
        //    alert.addAction(creditCard)
        alert.addAction(paypal)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func paypal(){
        braintreeClient = BTAPIClient(authorization: AppSettings.paypalAuthorizationToken)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        //        payPalDriver.viewControllerPresentingDelegate = self
        //        payPalDriver.appSwitchDelegate = self // Optional
        
        // Specify the transaction amount here. "2.32" is used in this example.
        let request = BTPayPalCheckoutRequest(amount: "10.00")
        //        let request = BTPayPalRequest(amount: "10.00")
        request.currencyCode = "USD" // Optional; see BTPayPalRequest.h for more options
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
                
                self.upgradeMemberShip()
            } else if let error = error {
                log.verbose("error = \(error.localizedDescription ?? "")")
            } else {
                log.verbose("error = \(error?.localizedDescription ?? "")")
                
            }
        }
    }
}

//extension UpgradeVC:BTAppSwitchDelegate, BTViewControllerPresentingDelegate{
//    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
//        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
//    }
//
//    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
//        log.verbose("Switched")
//
//    }
//
//    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
//        self.dismissProgressDialog {
//            log.verbose("Switched")
//        }
//
//    }
//
//    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
//        present(viewController, animated: true, completion: nil)
//
//
//    }
//
//    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
//        dismiss(animated: true, completion: nil)
//
//    }
//}
extension UpgradeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.upgardeArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpgradeUser", for: indexPath) as! UpgradeUserCell
        
        let index = self.upgardeArray[indexPath.row]
        cell.vc = self
        
        let type  = index["BtnType"] as? String
        cell.type = type
        if type == "0"{
            cell.upgradeBtn.setTitle(NSLocalizedString("Free", comment: "Free"), for: .normal)
        }else{
            cell.upgradeBtn.setTitle(NSLocalizedString("Upgrade Now", comment: "Upgrade Now"), for: .normal)
        }
        if let price = index["price"] as? String{
            cell.priceLabel.text = "\("$")\(price)"
        }
        
        if let type = index["pro_type"] as? String{
            cell.proType.text = type
        }
        if let post = index["upload_limit"] as? String{
            cell.featuredLabel.text = post
        }
        if let page = index["ads"] as? String{
            cell.profileVisitorLabel.text = page
        }
        if let feature = index["featured"] as? String{
            cell.hideLastSeenLabel.text = feature
        }
        if let badge = index["badge"] as? String{
            cell.verifiedLabel.text = badge
        }
        if let sell = index["sell"] as? String{
            cell.postPromotionLabel.text = sell
        }
        if let color = index["BtnColor"] as? String{
            cell.upgradeBtn.backgroundColor = UIColor.hexStringToUIColor(hex: color)
            cell.priceLabel.textColor = UIColor.hexStringToUIColor(hex: color)
            cell.proType.textColor = UIColor.hexStringToUIColor(hex: color)
        }
        if let image = index["main_image"] as? String{
            if image == "Shape-2"{
                cell.mainImage.image = #imageLiteral(resourceName: "Shape-2")
            }
            else if image == "badge"{
                cell.mainImage.image = UIImage(named: "badge")
            }
            
        }
        
        cell.upgradeBtn.tag = indexPath.row
        //        cell.upgradeBtn.addTarget(self, action: #selector(self.startCheckout(Type:type ?? "")), for: .touchUpInside)
        //        if ControlSettings.showPaymentVC == true{
        //        cell.upgradeBtn.addTarget(self, action: #selector(self.startCheckout), for: .touchUpInside)
        //        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200.0, height: 350.0)
    }
    
    
    
}

//extension UpgradeVC:PayPalPaymentDelegate{
//    // PayPalPaymentDelegate
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        print("PayPal Payment Cancelled")
//        paymentViewController.dismiss(animated: true, completion: nil)
//    }
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        print("PayPal Payment Success !")
//        self.upgradeMemberShip()
//        paymentViewController.dismiss(animated: true, completion: { () -> Void in
//            
//            print("Here is your proof of payment:nn(completedPayment.confirmation)nnSend this to your server for confirmation and fulfillment.")
//        })
//    }
//}
