

import UIKit
import Async
import PlaytubeSDK
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class RegisterVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var facebookButtonView: UIView!
    @IBOutlet weak var woWonderButtonView: UIView!
    @IBOutlet weak var appleButtonView: UIView!
    @IBOutlet weak var googleButtonView: UIView!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    // MARK: - Properties
    
    var genderValue = "Male"
    var status = false
    var agree = false
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Password Toggle Button Action
    @IBAction func passwordToggleButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            self.txtPass.isSecureTextEntry = !self.txtPass.isSecureTextEntry
            sender.setImage(UIImage(named: !self.txtPass.isSecureTextEntry ? "eye_hide" : "eye_show"), for: .normal)
        } else {
            self.txtConfirmPass.isSecureTextEntry = !self.txtConfirmPass.isSecureTextEntry
            sender.setImage(UIImage(named: !self.txtConfirmPass.isSecureTextEntry ? "eye_hide" : "eye_show"), for: .normal)
        }
    }
    
    // Male Button Action
    @IBAction func maleButtonAction(_ sender: UIButton) {
        self.genderValue = "Male"
        self.btnMale.setImage(UIImage(named: "radio_select"), for: .normal)
        self.btnMale.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnFemale.setImage(UIImage(named: "radio_unselect"), for: .normal)
        self.btnFemale.setTitleColor(UIColor(red: 115/255, green: 120/255, blue: 132/255, alpha: 1), for: .normal)
    }
    
    // Female Button Action
    @IBAction func femaleButtonAction(_ sender: UIButton) {
        self.genderValue = "Female"
        self.btnFemale.setImage(UIImage(named: "radio_select"), for: .normal)
        self.btnFemale.setTitleColor(UIColor(red: 15/255, green: 100/255, blue: 247/255, alpha: 1), for: .normal)
        self.btnMale.setImage(UIImage(named: "radio_unselect"), for: .normal)
        self.btnMale.setTitleColor(UIColor(red: 115/255, green: 120/255, blue: 132/255, alpha: 1), for: .normal)
    }
    
    // Check Box Button Action
    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        self.status = !self.status
        if self.status {
            self.checkBoxButton.setImage(UIImage(named: "checkBox"), for: .normal)
            self.agree = true
        } else {
            self.checkBoxButton.setImage(UIImage(named: "unCheckBox"), for: .normal)
            self.agree = false
        }
    }
    
    // Terms And Condition Button Action
    @IBAction func termsConditionButtonAction(_ sender: UIButton) {
        let aboutUsURL = URL(string: API.WEBSITE_URL.TermsOfUse)
        UIApplication.shared.openURL(aboutUsURL!)
    }
    
    // SignUp Button Action
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        self.register(username: self.txtUsername.text, email: self.txtEmail.text, password: self.txtPass.text, confirmpass: self.txtPass.text, gender: genderValue)
    }
    
    // Google SignIn Button Action
    @IBAction func googleButtonAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    // FaceBook Button Action
    @IBAction func faceBookButtonAction(_ sender: UIButton) {
        self.facebookLogin()
    }
    
    // WoWonder Button Action
    @IBAction func woWonderButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.auth.loginWithWoWonderVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Apple Button Action
    @IBAction func appleButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.handleAppleIdRequest()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupUI()
    }
    
    // Setup UI
    func setupUI() {
        if AppSettings.showAppleLogin {
            self.appleButtonView.isHidden = false
        } else {
             self.appleButtonView.isHidden = true
        }
        
        if AppSettings.showFacebookLogin {
            self.facebookButtonView.isHidden = false
        } else {
            self.facebookButtonView.isHidden = true
        }
        
        if AppSettings.showGoogleLogin {
            self.googleButtonView.isHidden = false
        } else {
            self.googleButtonView.isHidden = true
        }
        
        if AppSettings.showWoWonderLogin {
            self.woWonderButtonView.isHidden = false
        } else {
            self.woWonderButtonView.isHidden = true
        }
        
    }
    
    @available(iOS 13.0, *)
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    // MARK: Registration API call
    func register(username: String?, email: String?, password: String?, confirmpass: String?, gender: String?) {
        if appDelegate.isInternetConnected {
            print(API.AUTH_Constants_Methods.REGISTER_API)
            print(API.SERVER_KEY.Server_Key)
            if (username?.isEmpty)! {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                securityAlertVC?.errorText = NSLocalizedString("Please enter username.", comment: "Please enter username.")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else if (email?.isEmpty)! {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                securityAlertVC?.errorText = NSLocalizedString("Please enter email.", comment: "Please enter email.")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else if !self.agree {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                securityAlertVC?.errorText = NSLocalizedString("Please select the Terms & Conditions.", comment: "Please select the Terms & Conditions.")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else if (password?.isEmpty)! {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                securityAlertVC?.errorText = NSLocalizedString("Please enter password.", comment: "Please enter password.")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else {
                self.showLoaderAndHideButton(btn: self.btnSignup, loader: self.activityInd)
                // self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
                let username = username ?? ""
                let email = email ?? ""
                let password = password ?? ""
                let confirmPassword = confirmpass ?? ""
                let gender = gender ?? ""
                let deviceId = self.deviceID ?? ""
                Async.background {
                    UserManager.instance.RegisterUser(Email: email, UserName: username, Password: password, ConfirmPassword: confirmPassword, deviceID: deviceId, gender: gender, completionBlock: { (success, emailError, sessionError, error) in
                        if success != nil {
                            Async.main {
                                log.verbose("Success = \(success?.message ?? "")")
                                self.dismissLoaderAndHideButton(btn: self.btnSignup, loader: self.activityInd)
                                self.dismissProgressDialog {
                                    AppInstance.instance.userType = 1
                                    let vc = R.storyboard.loggedUser.tabBarNav()
                                    self.appDelegate.window?.rootViewController = vc
                                }
                            }
                        } else if emailError != nil {
                            Async.main {
                                self.dismissLoaderAndHideButton(btn: self.btnSignup, loader: self.activityInd)
                                self.dismissProgressDialog {
                                    log.verbose("EmailSuccess = \(emailError?.message ?? "")")
                                    let vc = R.storyboard.popups.emailVerificationVC()
                                    self.present(vc!, animated: true, completion: nil)
                                }
                            }
                        } else if sessionError != nil {
                            Async.main {
                                self.dismissLoaderAndHideButton(btn: self.btnSignup, loader: self.activityInd)
                                self.dismissProgressDialog {
                                    log.verbose("AuthError = \(sessionError?.errors!.error_text ?? "")")
                                    self.view.makeToast(sessionError?.errors!.error_text ?? "")
                                }
                            }
                        } else {
                            Async.main {
                                if let err = error as? NSDictionary {
                                    if let errors = err.object(forKey: "errors") as? NSDictionary {
                                        if let error_text = errors.object(forKey: "error_text") as? String {
                                            self.dismissLoaderAndHideButton(btn: self.btnSignup, loader: self.activityInd)
                                            self.dismissProgressDialog {
                                                log.verbose("Error = \(error_text)")
                                                self.view.makeToast(error_text)
                                            }
                                        }
                                    } else {
                                        self.dismissLoaderAndHideButton(btn: self.btnSignup, loader: self.activityInd)
                                        self.dismissProgressDialog {
                                            log.verbose("Error = \(error?.localizedDescription ?? "")")
                                            self.view.makeToast(error?.localizedDescription ?? "")
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
            }
        } else {
            self.dismissLoaderAndHideButton(btn: self.btnSignup, loader: self.activityInd)
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error", comment: "Internet Error")
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    
    // MARK: Facebook Login
    func facebookLogin() {
        if Connectivity.isConnectedToNetwork() {
            let fbLoginManager: LoginManager = LoginManager()
            fbLoginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) in
                if (error == nil) {
                    self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
                    let fbloginresult: LoginManagerLoginResult = result!
                    if (result?.isCancelled)! {
                        self.dismissProgressDialog {
                            log.verbose("result.isCancelled = \(result?.isCancelled ?? false)")
                        }
                        return
                    }
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((AccessToken.current) != nil) {
                            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completion: { (connection, result, error) -> Void in
                                if (error == nil) {
                                    let dict = result as! [String : AnyObject]
                                    log.debug("result = \(dict)")
                                    guard (dict["first_name"] as? String) != nil else {return}
                                    guard (dict["last_name"] as? String) != nil else {return}
                                    guard (dict["email"] as? String) != nil else {return}
                                    let accessToken = AccessToken.current?.tokenString ?? ""
                                    let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
                                    Async.background {
                                        UserManager.instance.facebookLogin(Provider: "facebook", AccessToken: accessToken, DeviceID: deviceId, completionBlock: { (success, sessionError, error) in
                                            if success != nil {
                                                Async.main {
                                                    self.dismissProgressDialog {
                                                        log.verbose("Success = \(success?.data?.message ?? "")")
                                                        AppInstance.instance.getUserSession()
                                                        AppInstance.instance.fetchUserProfile { (success) in
                                                            if (success) {
                                                                print(true)
                                                                AppInstance.instance.userType = 1
                                                                let vc = R.storyboard.loggedUser.tabBarNav()
                                                                self.appDelegate.window?.rootViewController = vc
                                                                self.view.makeToast("Login Successfull!!")
                                                            } else {
                                                                print(false)
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if sessionError != nil {
                                                Async.main {
                                                    self.dismissProgressDialog {
                                                        log.verbose("session Error = \(sessionError?.errors?.error_text ?? "")")
                                                        let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                                        securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                                                        securityAlertVC?.errorText = sessionError?.errors?.error_text ?? ""
                                                        self.present(securityAlertVC!, animated: true, completion: nil)
                                                    }
                                                }
                                            } else {
                                                Async.main {
                                                    self.dismissProgressDialog {
                                                        log.verbose("error = \(error?.localizedDescription ?? "")")
                                                        let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                                        securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                                                        securityAlertVC?.errorText = error?.localizedDescription ?? ""
                                                        self.present(securityAlertVC!, animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                        })
                                    }
                                    log.verbose("FBSDKAccessToken.current() = \(accessToken)")
                                }
                            })
                        }
                    }
                }
            })
        } else {
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error", comment: "Internet Error")
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    
    // MARK: Google Login
    func googleLogin(access_Token: String) {
        Async.background {
            let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
            UserManager.instance.googleLogin(Provider: "google", AccessToken: access_Token, GoogleApiKey: "AIzaSyA-JSf9CU1cdMpgzROCCUpl4wOve9S94ZU", DeviceID: deviceId, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug(success?.data!.message ?? "")
                            AppInstance.instance.getUserSession()
                            AppInstance.instance.fetchUserProfile { (success) in
                                if (success) {
                                    print(true)
                                    AppInstance.instance.userType = 1
                                    let vc = R.storyboard.loggedUser.tabBarNav()
                                    self.appDelegate.window?.rootViewController = vc
                                } else {
                                    print(false)
                                }
                            }
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug(sessionError?.errors!.error_text ?? "")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug(error?.localizedDescription ?? "")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: Apple Login
    func appleLogin(access_Token: String) {
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        if Connectivity.isConnectedToNetwork() {
            let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
            Async.background {
                UserManager.instance.applelogin(Provider: "apple", AccessToken: access_Token, DeviceID: deviceId) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug(success?.data!.message ?? "")
                                AppInstance.instance.getUserSession()
                                AppInstance.instance.fetchUserProfile { (success) in
                                    if (success) {
                                        print(true)
                                        AppInstance.instance.userType = 1
                                        let vc = R.storyboard.loggedUser.tabBarNav()
                                        self.appDelegate.window?.rootViewController = vc
                                    } else {
                                        print(false)
                                    }
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug(sessionError?.errors!.error_text ?? "")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug(error?.localizedDescription ?? "")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        }
                    }
                }
            }
        } else {
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error", comment: "Internet Error")
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    
}

// MARK: - Extensions

// MARK: GIDSignInDelegate Methods
extension RegisterVC: GIDSignInDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            _ = user.userID ?? ""
            log.verbose("user auth = \(user.authentication.accessToken ?? "")")
            let accessToken = user.authentication.idToken ?? ""
            self.googleLogin(access_Token: user.authentication.idToken)
        } else {
            log.error(error.localizedDescription)
        }
    }
    
}

// MARK: ASAuthorizationControllerDelegate Methods
extension RegisterVC: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.authorizationCode
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let authorizationCode = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
            print("authorizationCode: \(authorizationCode)")
            self.appleLogin(access_Token: authorizationCode)
            print("User id is \(userIdentifier ?? Data()) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))") }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error sign in with apple")
    }
    
}
