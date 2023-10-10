import UIKit
import Async
import Toast_Swift
import FBSDKLoginKit
import GoogleSignIn
import PlaytubeSDK
import AuthenticationServices

class LoginVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var facebookButtonView: UIView!
    @IBOutlet weak var googleButtonView: UIView!
    @IBOutlet weak var woWonderButtonView: UIView!
    @IBOutlet weak var appleButtonView: UIView!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
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
        self.txtPassword.isSecureTextEntry = !self.txtPassword.isSecureTextEntry
        sender.setImage(UIImage(named: !self.txtPassword.isSecureTextEntry ? "eye_hide" : "eye_show"), for: .normal)
    }
    
    // Login Button Action
    @IBAction func loginButtonAction(_ sender: UIButton) {
        self.loginPressed(email: self.txtUsername.text, password: self.txtPassword.text)
    }
    
    // Forgot Password Button Action
    @IBAction func forgotPasswordButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.auth.forgetPasswordVC()
        self.navigationController?.pushViewController(vc!, animated: true)
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
    
    // Register Button Action
    @IBAction func registerButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.auth.registerVC()
        self.navigationController?.pushViewController(vc!, animated: true)
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
    func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    // MARK: Login API call
    func loginPressed(email: String?, password: String?) {
        if appDelegate.isInternetConnected {
            if (email?.isEmpty)! {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                securityAlertVC?.errorText = NSLocalizedString("Please enter username.", comment: "Please enter username.")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else if (password?.isEmpty)! {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
                securityAlertVC?.errorText = NSLocalizedString("Please enter password.", comment: "Please enter password.")
                self.present(securityAlertVC!, animated: true, completion: nil)
            } else {
                self.showLoaderAndHideButton(btn: self.btnLogin, loader: self.activityInd)
                // self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
                let email = email ?? ""
                let password = password ?? ""
                let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
                Async.background {
                    UserManager.instance.authenticateUser(UserName: email, Password: password, deviceID: deviceId, completionBlock: { (success, sessionError,userID,error) in
                        if success != nil {
                            Async.main {
                                self.dismissLoaderAndHideButton(btn: self.btnLogin, loader: self.activityInd)
                                self.dismissProgressDialog {
                                    log.verbose("Success = \(success?.data?.sessionID ?? "")")
                                    AppInstance.instance.getUserSession()
                                    AppInstance.instance.fetchUserProfile { (success) in
                                        if (success) {
                                            print("true")
                                        } else {
                                            print("false")
                                        }
                                    }
                                    UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                    AppInstance.instance.userType = 1
                                    let vc = R.storyboard.loggedUser.tabBarNav()
                                    self.appDelegate.window?.rootViewController = vc
                                    self.view.makeToast("Login Successfull!!")
                                }
                            }
                        } else if userID != nil {
                            Async.main {
                                self.dismissLoaderAndHideButton(btn: self.btnLogin, loader: self.activityInd)
                                self.dismissProgressDialog {
                                    let vc = R.storyboard.auth.twoFactorVC()
                                    vc?.userID = userID ?? 0
                                    vc?.password = password
                                    vc?.modalPresentationStyle = .fullScreen
                                    self.present(vc!, animated: true, completion: nil)
                                    self.view.makeToast("Login Successfull!!")
                                }
                            }
                        } else if sessionError != nil {
                            Async.main {
                                self.dismissLoaderAndHideButton(btn: self.btnLogin, loader: self.activityInd)
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
                                self.dismissLoaderAndHideButton(btn: self.btnLogin, loader: self.activityInd)
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
            }
        } else {
            self.dismissLoaderAndHideButton(btn: self.btnLogin, loader: self.activityInd)
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error", comment: "Internet Error")
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    
    // MARK: Facebook login
    func facebookLogin() {
        if Connectivity.isConnectedToNetwork() {
            let fbLoginManager: LoginManager = LoginManager()
            fbLoginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) in
                if (error == nil){
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
                                    let dict = result as! [String: AnyObject]
                                    log.debug("result = \(dict)")
                                    guard (dict["first_name"] as? String) != nil else { return }
                                    guard (dict["last_name"] as? String) != nil else { return }
                                    guard (dict["email"] as? String) != nil else { return }
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
                                                            if (success){
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
                    if success != nil{
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
extension LoginVC: GIDSignInDelegate {
    
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
extension LoginVC: ASAuthorizationControllerDelegate {
    
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
