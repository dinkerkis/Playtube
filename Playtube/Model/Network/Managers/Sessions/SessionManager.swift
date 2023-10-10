//
//  SessionManager.swift
//  Playtube
//
//  Created by iMac on 22/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class SessionManager {
    
    static let sharedInstance = SessionManager()
    
    private init() {
        
    }
    
    func getSession(completionBlock: @escaping (_ Success: SessionModal.GetSession_SuccessModal?, _ AuthError: SessionModal.GetSession_ErrorModal?, Error?)-> () ) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.Comment_Type: "get",
            API.Params.session_token: AppInstance.instance.sessionId ?? ""
        ] as [String : Any]
        print("Params", params)
        AF.request(API.SessionsMethods.SessionsApi, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let api_status = res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(SessionModal.GetSession_SuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(SessionModal.GetSession_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func deleteSession(id: Int, completionBlock: @escaping (_ Success: SessionModal.DeleteSession_SuccessModal?, _ AuthError: SessionModal.DeleteSession_ErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.Id: id,
            API.Params.Comment_Type: "delete"
        ] as [String: Any]
        AF.request(API.SessionsMethods.SessionsApi, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let api_status = res["api_status"] as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(SessionModal.DeleteSession_SuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(SessionModal.DeleteSession_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
