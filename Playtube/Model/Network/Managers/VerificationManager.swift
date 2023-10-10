

import Foundation
import Alamofire
import PlaytubeSDK


class VerificationManager:NSObject {
    
    static let instance = VerificationManager()
    
    func verifyUser(User_id: Int, Session_Token: String, FirstName: String, LastName: String, Message: String, Identity: Data?, completionBlock: @escaping (_ Success: VerificationModel.VerificationSuccessModel?, _ sessionError: VerificationModel.VerificationErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Message_Id : Message,
            API.Params.FirstName : FirstName,
            API.Params.LastName : LastName
        ] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = Identity {
                multipartFormData.append(data, withName: "identity", fileName: "identity.jpg", mimeType: "image/png")
            }
        }, to:API.Verification_Methods.VERIFICATION_API, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(VerificationModel.VerificationSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(VerificationModel.VerificationErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
