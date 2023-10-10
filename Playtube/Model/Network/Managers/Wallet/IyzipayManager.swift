//
//  IyzipayManager.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class IyzipayManager: NSObject {
    
    static let instance = IyzipayManager()
    
    func initializeIyzipayWalletApi(user_id: Int, session_token: String, amount: Int, completionBlock: @escaping (_ Success: IyzipayModel.Iyzipay_SuccessModal?, _ SessionError: IyzipayModel.Iyzipay_ErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.user_id : user_id,
            API.Params.session_token : session_token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Request: API.Params.Initialize,
            API.Params.Comment_Type : API.Params.Wallet,
            API.Params.Amount: amount
        ] as [String : Any]
        print(params)
        let URL = API.Iyzipay_Methods.IYZIPAY_API
        print("URL :=> ",URL)
        AF.request(URL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(IyzipayModel.Iyzipay_SuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(IyzipayModel.Iyzipay_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
