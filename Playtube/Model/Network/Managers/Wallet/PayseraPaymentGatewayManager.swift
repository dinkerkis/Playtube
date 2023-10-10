//
//  PayseraPaymentGatewayManager.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK


class PayseraPaymentGatewayManager: NSObject {
    
    static let instance = PayseraPaymentGatewayManager()
    /*
     //projectid:1
     */
    
    func payseraWalletAPI(user_id: Int, session_token: String, amount: Int, completionBlock: @escaping (_ Success: PayseraPaymentModel.PayseraPaymentSuccessModal?, _ SessionError: PayseraPaymentModel.PayseraPaymentErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.user_id : user_id,
            API.Params.session_token : session_token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : API.Params.Wallet,
            "projectid" : "1",
            "request" : "initialize",
            API.Params.Amount: amount
        ] as [String : Any]
        print(params)
        let URL = "\(API.Paysera_Methods.PAYSERA_API)"
        print("URL :=> ",URL)
        AF.request(URL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(PayseraPaymentModel.PayseraPaymentSuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PayseraPaymentModel.PayseraPaymentErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
}
