import Foundation
import Alamofire
import PlaytubeSDK
    
class UserManager: NSObject {
    
    static let instance = UserManager()
    
    //Authenticate User On Server
    func authenticateUser(UserName: String, Password: String, deviceID: String, completionBlock: @escaping (_ Success: LoginModel.UserSuccessModel?, _ AuthError: LoginModel.UserErrorModel?, _ TwoFactorUserID: Int?, Error?) -> () ) {
        let params = [
            API.Params.Username: UserName,
            API.Params.Password: Password,
            API.Params.device_id: deviceID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        AF.request(API.AUTH_Constants_Methods.LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("Result = \(Res)")
                guard let apiStatus = Res["api_status"]  as? String else { return }
                if apiStatus == "200" {
                    guard let successType = Res["success_type"]  as? String else { return }
                    if successType == "confirmation_email" {
                        guard let userID = Res["user_id"] as? Int else { return }
                        completionBlock(nil, nil, userID, nil)
                    } else {
                        let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                        let result = try? JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data!)
                        log.debug("Success = \(result?.data!.message ?? "")")
                        let User_Session = [
                            Local.USER_SESSION.cookie: (result?.data!.cookie ?? ""),
                            Local.USER_SESSION.session_id: (result?.data!.sessionID ?? ""),
                            Local.USER_SESSION.user_id: (result?.data!.userID ?? 0)
                        ] as [String : Any]
                        UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                        completionBlock(result, nil, nil, nil)
                    }
                } else if apiStatus == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data!)
                    completionBlock(nil, result, nil, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, nil, response.error)
            }
        }
    }
    
    func RegisterUser(Email: String, UserName: String, Password: String, ConfirmPassword: String, deviceID: String, gender: String, completionBlock: @escaping (_ Success: RegisterModel.RegisterSuccessModel?, _ EmailSucces: RegisterModel.RegisterEmailSuccessModel?, _ AuthError: RegisterModel.RegisterErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Username: UserName,
            API.Params.Email: Email,
            API.Params.Password: Password,
            API.Params.ConfirmPassword: ConfirmPassword,
            API.Params.device_id: deviceID,
            API.Params.Gender: gender,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        AF.request(API.AUTH_Constants_Methods.REGISTER_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("reponse = \(Res)")
                guard let apiStatus = Res["api_status"] as? String else { return }
                if apiStatus == "200" {
                    guard let message = Res["message"] as? String else { return }
                    if message == "Successfully joined, Please wait.." {
                        let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                        let result = try? JSONDecoder().decode(RegisterModel.RegisterSuccessModel.self, from: data!)
                        log.debug("Success = \(result?.message ?? "")")
                        let User_Session = [
                            Local.USER_SESSION.cookie: (result?.data!.cookie ?? ""),
                            Local.USER_SESSION.session_id: (result?.data!.s ?? ""),
                            Local.USER_SESSION.user_id: (result?.data!.userID ?? 0)
                        ] as [String: Any]
                        UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                        completionBlock(result, nil, nil, nil)
                    } else {
                        let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                        let result = try? JSONDecoder().decode(RegisterModel.RegisterEmailSuccessModel.self, from: data!)
                        log.debug("Success = \(result?.message ?? "")")
                        completionBlock(nil, result, nil, nil)
                    }
                } else if apiStatus == "304" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(RegisterModel.RegisterErrorModel.self, from: data!)
                    log.error("AuthError = \(result?.errors!.error_text ?? "")")
                    completionBlock(nil, nil, result, nil)
                } else if apiStatus == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(RegisterModel.RegisterErrorModel.self, from: data!)
                    log.error("AuthError = \(result?.errors!.error_text ?? "")")
                    completionBlock(nil, nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, nil, response.error)
            }
            
        }
        
    }
    
    func ForgetPassword(Email: String, completionBlock: @escaping (_ Success: ForgotPasswordModel.ForgotPasswordSuccessModel?, _ AuthError: ForgotPasswordModel.ForgotPasswordErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Email: Email,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        AF.request(API.AUTH_Constants_Methods.FORGETPASSWORD_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let apiStatus = Res["api_status"] as? String else { return }
                if apiStatus == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ForgotPasswordModel.ForgotPasswordSuccessModel.self, from: data!)
                    log.debug("Success = \(result?.data!.message ?? "")")
                    completionBlock(result, nil, nil)
                } else if apiStatus == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ForgotPasswordModel.ForgotPasswordErrorModel.self, from: data!)
                    log.error("AuthError = \(result?.errors!.error_text ?? "")")
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func deleteUser(User_id: Int, Session_Token: String, currentPassword: String, completionBlock: @escaping (_ Success: DeleteUserModel.DeleteUserSuccessModel?, _ SessionError: DeleteUserModel.DeleteUserErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.CurrentPassword: currentPassword,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Id: User_id
            ] as [String: Any]
        print(params)
        AF.request(API.AUTH_Constants_Methods.DELETE_USER_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DeleteUserModel.DeleteUserSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else /*if api_status == "400"*/{
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DeleteUserModel.DeleteUserErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func facebookLogin(Provider: String, AccessToken: String, DeviceID: String, completionBlock: @escaping (_ Success: LoginModel.UserSuccessModel?, _ AuthError: LoginModel.UserErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Provider: Provider,
            API.Params.AccessToken: AccessToken,
            API.Params.device_id: DeviceID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        AF.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data!)
                    log.debug("Success = \(result?.data!.message ?? "")")
                    let User_Session = [
                        Local.USER_SESSION.cookie: (result?.data!.cookie ?? ""),
                        Local.USER_SESSION.session_id: (result?.data!.sessionID ?? ""),
                        Local.USER_SESSION.user_id: (result?.data!.userID ?? 0)
                    ] as [String: Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result, nil, nil)
                } else if apiStatus == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data!)
                    log.error("AuthError = \(result?.errors!.error_text ?? "")")
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    func googleLogin(Provider: String, AccessToken: String, GoogleApiKey: String, DeviceID: String, completionBlock: @escaping (_ Success: LoginModel.UserSuccessModel?, _ AuthError: LoginModel.UserErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Provider: Provider,
            API.Params.AccessToken: AccessToken,
            API.Params.device_id: DeviceID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            // API.Params.Google_Key : GoogleApiKey
        ]
        AF.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("JsonPrint = \(Res)")
                guard let apiStatus = Res["api_status"]  as? String else { return }
                if apiStatus == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data!)
                    log.debug("Success = \(result?.data!.message ?? "")")
                    let User_Session = [
                        Local.USER_SESSION.cookie: (result?.data!.cookie ?? ""),
                        Local.USER_SESSION.session_id: (result?.data!.sessionID ?? ""),
                        Local.USER_SESSION.user_id: (result?.data!.userID ?? 0)
                    ] as [String: Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result, nil, nil)
                } else if apiStatus == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data!)
                    log.error("AuthError = \(result?.errors!.error_text ?? "")")
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func applelogin(Provider: String, AccessToken: String, DeviceID: String, completionBlock: @escaping (_ Success: LoginModel.UserSuccessModel?, _ AuthError: LoginModel.UserErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Provider: Provider,
            API.Params.AccessToken: AccessToken,
            API.Params.device_id: DeviceID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            // API.Params.Google_Key : GoogleApiKey
        ]
        AF.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("JsonPrint = \(Res)")
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data!)
                    log.debug("Success = \(result?.data!.message ?? "")")
                    let User_Session = [
                        Local.USER_SESSION.cookie: (result?.data!.cookie ?? ""),
                        Local.USER_SESSION.session_id: (result?.data!.sessionID ?? ""),
                        Local.USER_SESSION.user_id: (result?.data!.userID ?? 0)
                    ] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result, nil, nil)
                } else if apiStatus == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data!)
                    log.error("AuthError = \(result?.errors!.error_text ?? "")")
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func loginWithWoWonder(userName: String, password: String, completionBlock: @escaping (_ Success: LoginWithWoWonderModel.LoginWithWoWonderSuccessModel?, _ AuthError: ErrorModel?, Error?) -> () ) {
        let params  = [
            API.Params.ServerKey: AppSettings.wowonder_ServerKey,
            API.Params.Username: userName,
            API.Params.Password: password
        ]
        AF.request("\(AppSettings.wowonder_URL)api/auth", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatusCode = res["api_status"] else { return }
                let apiCode = apiStatusCode as? Int
                if apiCode == 200 {
                    guard let allData = try? JSONSerialization.data(withJSONObject: res, options: [])else { return }
                    guard let result = try? JSONDecoder().decode(LoginWithWoWonderModel.LoginWithWoWonderSuccessModel.self, from: allData) else {return}
                    completionBlock(result, nil, nil)
                } else {
                    guard let allData = try? JSONSerialization.data(withJSONObject: res, options: [])else { return }
                    guard let result = try? JSONDecoder().decode(ErrorModel.self, from: allData) else { return }
                    completionBlock(nil, result, nil)
                }
            } else {
                print(response.error?.localizedDescription ?? "")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func twoFactor(userID: Int, code: Int, completionBlock: @escaping (_ Success: LoginModel.UserSuccessModel?, _ AuthError: LoginModel.UserErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.code: code,
            API.Params.user_id: userID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.TwoFactorMethod.TwoFactor, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("Result = \(Res)")
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200"{
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data!)
                    log.debug("Success = \(result?.data!.message ?? "")")
                    let User_Session = [
                        Local.USER_SESSION.cookie: (result?.data!.cookie ?? ""),
                        Local.USER_SESSION.session_id: (result?.data!.sessionID ?? ""),
                        Local.USER_SESSION.user_id: (result?.data!.userID ?? 0)
                    ] as [String: Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result, nil, nil)
                }else if apiStatus == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
}
