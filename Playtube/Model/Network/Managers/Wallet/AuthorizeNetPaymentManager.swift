//
//  AuthorizeNetPaymentManager.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class AuthorizeNetPaymentManager: NSObject {
    
    static let instance = AuthorizeNetPaymentManager()

    func addWalletApi(user_id: Int,
                      session_token: String,
                      amount: Int,
                      card_number: String,
                      card_month: String,
                      card_year: String,
                      card_cvc: String,
                      completionBlock: @escaping (_ Success: AuthorizeNetPaymentModel.AuthorizeNetPaymentSuccessModal?, _ SessionError: AuthorizeNetPaymentModel.AuthorizeNetPaymentErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.user_id : user_id,
            API.Params.session_token : session_token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : "authorize",
            API.Params.Amount: amount,
            "card_number": card_number,
            "card_month": card_month,
            "card_year": card_year,
            "card_cvc": card_cvc
        ] as [String : Any]
        print(params)
        let URL = API.Wallet_Methods.WALLET_API
        print("URL :=> ",URL)
        AF.request(URL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(AuthorizeNetPaymentModel.AuthorizeNetPaymentSuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AuthorizeNetPaymentModel.AuthorizeNetPaymentErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
