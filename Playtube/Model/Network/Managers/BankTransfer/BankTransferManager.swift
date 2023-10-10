//
//  BankTransferManager.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 3/25/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class BankTransferManager {
    
    static let instance = BankTransferManager()
    
    func bankWalletApi(session_token: String, userID: Int, amount: Int, mediaData: Data?, completionBlock: @escaping (_ Success: BankTransferModel.BankTransferSuccessModel?, _ sessionError: BankTransferModel.BankTransferErrorModel?, Error?) ->()) {
        let params = [
            API.Params.session_token: session_token,
            API.Params.user_id: userID,
            API.Params.Comment_Type: API.Params.Wallet,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Amount: amount
        ] as [String: Any]
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let avatarData = mediaData {
                multipartFormData.append(avatarData, withName: "thumbnail", fileName: "m.jpg", mimeType: "image/png")
            }
        }, to: API.BankTransferMethod.bankTransfer, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            print("Succesfully uploaded")
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(BankTransferModel.BankTransferSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(BankTransferModel.BankTransferErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
}
