import Foundation
import Alamofire
import PlaytubeSDK

class MonetizationManager: NSObject {
    
    static let instance = MonetizationManager()
    
    func monetizeUser(User_id: Int, Session_Token: String, Email: String, Ammount: Int, completionBlock: @escaping (_ Success: MonetizationModel.MonetizationSuccessModel?, _ SessionError: MonetizationModel.MonetizationErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Amount : Ammount,
             API.Params.Email : Email
            ] as [String : Any]
        AF.request(API.Monetization_Methods.MONETIZATION_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("URL = \(API.Monetization_Methods.MONETIZATION_API + Session_Token)")
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MonetizationModel.MonetizationSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MonetizationModel.MonetizationErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
