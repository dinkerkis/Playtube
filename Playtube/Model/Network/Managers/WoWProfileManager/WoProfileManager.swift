//
//  WoProfileManager.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 3/30/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class WoWProfileManager {
    
    static let instance = WoWProfileManager()
    
    func WoWonderUserData(userId: String, access_token: String, completionBlock: @escaping (_ Success: LoginModel.UserSuccessModel?, _ AuthError: LoginModel.UserErrorModel?, Error?) -> () ) {
        let params = [API.Params.ServerKey: AppSettings.wowonder_ServerKey, API.Params.user_id: userId, API.Params.Fetch: "followers,user_data,followers,following,liked_pages,joined_groups"] as [String: Any]
        AF.request("\(AppSettings.wowonder_URL)api/get-user-data?access_token=" + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatusCode = res["api_status"] else { return }
                let apiCode = apiStatusCode as? Int
                if apiCode == 200 {
                    let base64String = self.jsonToBaseString(yourJSON: res)
                    var params = [String: String]()
                    params = [
                        API.Params.Provider: "wowonder",
                        API.Params.AccessToken: base64String!,
                        API.Params.device_id: UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId),
                        API.Params.ServerKey: API.SERVER_KEY.Server_Key
                    ]
                    let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
                    let decoded = String(data: jsonData, encoding: .utf8)!
                    log.verbose("Targeted URL = \(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API)")
                    log.verbose("Decoded String = \(decoded)")
                    AF.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
                        if let res = response.value as? [String: Any] {
                            log.verbose("Response = \(res)")
                            guard let apiStatus = res["api_status"]  as? String else {return}
                            if apiStatus ==  "200" {
                                log.verbose("apiStatus Int = \(apiStatus)")
                                let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                                let result = try! JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data)
                                log.debug("Success = \(result.data?.sessionID ?? "")")
                                let User_Session = [Local.USER_SESSION.session_id:result.data?.sessionID as Any,Local.USER_SESSION.user_id:result.data?.userID as Any] as [String : Any]
                                UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                                completionBlock(result, nil, nil)
                            } else if apiStatus == "400" {
                                let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                                let result = try? JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data!)
                                log.error("AuthError = \(result?.errors?.error_text ?? "")")
                                completionBlock(nil, result, nil)
                            }
                        } else {
                            log.error("error = \(response.error?.localizedDescription ?? "")")
                            completionBlock(nil, nil, response.error)
                        }
                    }
                } else {
                    completionBlock(nil, nil, nil)
                }
            } else {
                print(response.error?.localizedDescription ?? "")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func jsonToBaseString (yourJSON: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: yourJSON, options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData.base64EncodedString(options: .endLineWithCarriageReturn)
        } catch {
            return nil
        }
    }
    
}
