//
//  CashfreeManager.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class CashfreeManager: NSObject {
    
    static let instance = CashfreeManager()
    
    func initializeCashfreeWalletApi(user_id: Int, session_token: String, name: String, email: String, phone: String, amount: Int, completionBlock: @escaping (_ Success: CashfreeModel.Cashfree_SuccessModal?, _ SessionError: CashfreeModel.Cashfree_ErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.user_id : user_id,
            API.Params.session_token : session_token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Request: API.Params.Initialize,
            API.Params.Comment_Type : API.Params.Wallet,
            API.Params.Name: name,
            API.Params.Email: email,
            API.Params.Phone: phone,
            API.Params.Amount: amount
        ] as [String : Any]
        print(params)
        let URL = API.Cashfree_Methods.CASHFREE_API
        print("URL :=> ",URL)
        AF.request(URL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                if (Res["api_status"] as? Int) == 200 {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(CashfreeModel.Cashfree_SuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if (Res["api_status"] as? String) == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CashfreeModel.Cashfree_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
