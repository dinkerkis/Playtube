//
//  WalletVC.swift
//  Playtube
//
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Toast_Swift
import Razorpay
import PlaytubeSDK
import Async
import Alamofire
import CashfreePG
import CashfreePGCoreSDK
import Braintree

protocol WalletVCDelegate {
    func handleAddMoneyInWalletForPurchase()
}

class WalletVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var imageUserProfile: RoundImage!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    // MARK: - Properties
    
    let site_settings = UserDefaults.standard.getSettings()
    var braintreeClient: BTAPIClient?
    var razorpayObj: RazorpayCheckout? = nil
    var cfPaymentGatewayService = CFPaymentGatewayService.getInstance()
    var amount = 0
    var isPurchase = false
    var delegate: WalletVCDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Continue Button Action
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.amount = Int(self.amountTextField.text ?? "") ?? 0
        if amountTextField.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Error, Please enter amount")
            return
        }
        if self.amount < 100 {
            self.view.makeToast("Error, Please enter amount minimum 100")
            return
        }
        let paymentOptionPopupVC = R.storyboard.popups.paymentOptionPopupVC()
        paymentOptionPopupVC?.delegate = self
        self.present(paymentOptionPopupVC!, animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setUserData()
    }
    
    // Set User Data
    func setUserData() {
        AppInstance.instance.fetchUserProfile { success in
            if success {
                self.amountTextField.text = ""
                self.amount = 0
                self.lblName.text = AppInstance.instance.userProfile?.data?.name ?? ""
                self.lblUsername.text = "@"+(AppInstance.instance.userProfile?.data?.username ?? "")
                self.imageUserProfile.sd_setImage(with: URL(string: AppInstance.instance.userProfile?.data?.avatar ?? ""))
                self.lblBalance.text = "\(AppInstance.instance.userProfile?.data?.wallet?.rounded() ?? 0.0)"
            }
        }
    }
    
}

// MARK: - Extensions

// MARK: PaymentOptionPopupVCDelegate
extension WalletVC: PaymentOptionPopupVCDelegate {
    
    func handlePaymentOptionTapped(paymentOption: String) {
        switch paymentOption {
        case "Paypal":
            self.startPaypalCheckout()
        case "Credit Card":
            let newVC = R.storyboard.settings.paymentCardVC()
            newVC?.paymentType = "creditcard"
            newVC?.amount = self.amount
            newVC?.delegate = self
            self.navigationController?.pushViewController(newVC!, animated: true)
        case "Bank Transfer":
            let newVC = R.storyboard.settings.bankTransferVC()
            newVC?.amount = self.amount
            self.navigationController?.pushViewController(newVC!, animated: true)
        case "RazorPay":
            self.view.makeToast("Please wait.....")
            self.openRazorpayCheckout()
        case "Paystack":
            let popupVC = R.storyboard.popups.payStackEmailPopupVC()
            popupVC?.delegate = self
            self.present(popupVC!, animated: true)
        case "Cashfree":
            let popupVC = R.storyboard.popups.cashfreePopupVC()
            popupVC?.delegate = self
            self.present(popupVC!, animated: true)
        case "Paysera":
            self.payseraPaymentGatewayAPI()
        case "AuthorizeNet":
            let newVC = R.storyboard.settings.paymentCardVC()
            newVC?.paymentType = "authorize"
            newVC?.amount = self.amount
            newVC?.delegate = self
            self.navigationController?.pushViewController(newVC!, animated: true)
        case "IyziPay":
            self.initializeIyzipayWalletApi(amount: self.amount)
        case "FlutterWave":
            self.view.makeToast("Coming Soon...")
        default:
            break;
        }
    }
    
}

// MARK: Api Call
extension WalletVC {
    
    func adsWalletApi(amount: Int) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                WalletManager.instance.adsWalletApi(user_id: userID, session_token: sessionID, amount: amount, completionBlock: { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("success \(success?.message ?? "") ")
                                self.setUserData()
                                if self.isPurchase {
                                    self.navigationController?.popViewController(animated: true)
                                    self.delegate?.handleAddMoneyInWalletForPurchase()
                                }
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    } else {
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: PaySera Setup
extension WalletVC {
    
    func payseraPaymentGatewayAPI() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                PayseraPaymentGatewayManager.instance.payseraWalletAPI(user_id: userID, session_token: sessionID, amount: self.amount) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                print(success?.url ?? "")
                                if let urlSTR = success?.url {
                                    if let newVC = R.storyboard.settings.walletWebViewVC() {
                                        newVC.modalPresentationStyle = .overFullScreen
                                        newVC.modalTransitionStyle = .crossDissolve
                                        newVC.paymentType = "paysera"
                                        newVC.urlString = urlSTR
                                        newVC.paystackDelegate = self
                                        self.present(newVC, animated: true)
                                    }
                                }
                            }
                        })
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors!.error_text)
                            log.verbose("SessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                    } else {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: Paypal Setup
extension WalletVC {
    
    func startPaypalCheckout() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            self.braintreeClient = BTAPIClient(authorization: AppSettings.paypalAuthorizationToken)!
            let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient!)
            let request = BTPayPalCheckoutRequest(amount: "\(self.amount)")
            request.currencyCode = "USD"
            payPalDriver.tokenizePayPalAccount(with: request) { tokenizedPayPalAccount, error in
                if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                    self.dismissProgressDialog {
                        print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                        self.adsWalletApi(amount: self.amount)
                    }
                } else if let error = error {
                    self.dismissProgressDialog {
                        self.view.makeToast(error.localizedDescription)
                        log.verbose("error = \(error.localizedDescription)")
                    }
                } else {
                    self.dismissProgressDialog {
                        self.view.makeToast(error?.localizedDescription ?? "")
                        log.verbose("error = \(error?.localizedDescription ?? "")")
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: Authorize Net
extension WalletVC: PaymentCardViewDelegate {
    
    func cardView(_ isSuccess: Bool) {
        if isSuccess {
            self.adsWalletApi(amount: self.amount)
        }
    }
    
}

//MARK: PayStack
extension WalletVC: PayStackEmailPopupVCDelegate, PaystackWalletWebViewDelegate {
    
    func webView(_ isSuccess: Bool, referanceID: String) {
        if isSuccess {
            self.adsWalletApi(amount: self.amount)
        }
    }
    
    func handlePayStackPayNowButtonTap(email: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                PayStackPaymentGatewayManager.instance.payStackWalletAPI(user_id: userID, session_token: sessionID, email: email, amount: self.amount) { (success, sessionError, error) in
                    if success != nil{
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                print(success?.url ?? "")
                                if let urlSTR = success?.url {
                                    if let newVC = R.storyboard.settings.walletWebViewVC() {
                                        newVC.modalPresentationStyle = .overFullScreen
                                        newVC.modalTransitionStyle = .crossDissolve
                                        newVC.paymentType = "paystack"
                                        newVC.urlString = urlSTR
                                        newVC.paystackDelegate = self
                                        self.present(newVC, animated: true)
                                    }
                                }
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors!.error_text)
                            log.verbose("SessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                    } else {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: Razorpay Setup
extension WalletVC: RazorpayPaymentCompletionProtocolWithData {
    
    private func openRazorpayCheckout() {
        let razorpayKey = self.site_settings?["razorpay_key_id"] as? String ?? ""
        razorpayObj = RazorpayCheckout.initWithKey(razorpayKey, andDelegateWithData: self)
        let options: [AnyHashable:Any] = [
            "prefill": [
                "name": AppInstance.instance.userProfile?.data?.name ?? "",
                "contact": AppInstance.instance.userProfile?.data?.phone_number ?? "",
                "email": AppInstance.instance.userProfile?.data?.email ?? ""
            ],
            "image": UIImage(named: "app_logo")!,
            "currency": "INR",
            "amount" : self.amount,
            "name": (self.site_settings?["name"] as? String ?? ""),
            "theme": [
                "color": "#254886"
            ]
        ]
        if let rzp = self.razorpayObj {
            rzp.open(options, displayController: self)
        } else {
            print("Unable to initialize")
        }
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        if let theObject = response {
            print(theObject)
            self.adsWalletApi(amount: self.amount)
        } else {
            self.view.makeToast("Something went wrong, please try again")
        }
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        self.view.makeToast(str)
    }
    
}

// MARK: Cashfree Setup
extension WalletVC: CashfreePopupVCDelegate, CFResponseDelegate {
    
    func handleCashfreePayNowButtonTap(name: String, email: String, phone: String) {
        self.initializeCashfreeWalletApi(name: name, email: email, phone: phone, amount: self.amount)
    }
    
    func initializeCashfreeWalletApi(name: String, email: String, phone: String, amount: Int) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                CashfreeManager.instance.initializeCashfreeWalletApi(user_id: userID, session_token: sessionID, name: name, email: email, phone: phone, amount: amount, completionBlock: { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast("Coming Soon...")
                                /*self.cfPaymentGatewayService.setCallback(self)*/
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    } else {
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func onError(_ error: CashfreePGCoreSDK.CFErrorResponse, order_id: String) {
        
    }
    
    func verifyPayment(order_id: String) {
        
    }
    
}

// MARK: Iyzipay Setup
extension WalletVC: IyzipayWalletWebViewDelegate {
    
    func initializeIyzipayWalletApi(amount: Int) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                IyzipayManager.instance.initializeIyzipayWalletApi(user_id: userID, session_token: sessionID, amount: amount, completionBlock: { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                if let iyzipayJS = success?.data {
                                    if let newVC = R.storyboard.settings.walletWebViewVC() {
                                        newVC.modalPresentationStyle = .overFullScreen
                                        newVC.modalTransitionStyle = .crossDissolve
                                        newVC.iyzipayDelegate = self
                                        newVC.paymentType = "iyzipay"
                                        newVC.iyzipayJS = iyzipayJS
                                        self.present(newVC, animated: true)
                                    }
                                }
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    } else {
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
}
