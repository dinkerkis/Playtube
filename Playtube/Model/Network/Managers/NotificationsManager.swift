import Foundation
import Alamofire
import PlaytubeSDK

class NotificationsManager: NSObject {
    
    static let instance = NotificationsManager()
    
    func getNotifications(User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success: NotificationsModel.NotificationsSuccessModel?, _ SessionError: NotificationsModel.NotificationsErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            ] as [String: Any]
        AF.request(API.NOTIFICATIONS_Methods.NOTIFICATIONS_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("RESONSE = \(Res)")
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(NotificationsModel.NotificationsSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(NotificationsModel.NotificationsErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }        
    }
    
}
