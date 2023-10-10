import Foundation
import Alamofire
import PlaytubeSDK

class BlockedUserManager: NSObject {
    
    static let instance = BlockedUserManager()
    
    func getBlockedUser(User_id: Int, Session_Token: String, type: String, completionBlock: @escaping (_ Success: GetBlockedUserModel.GetBlockedUserSuccessModel?, _ SessionError: GetBlockedUserModel.GetBlockedUserErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : type,
        ] as [String : Any]
        AF.request(API.BLocked_User_Methods.BLOCKED_USER_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            log.verbose("URL = \(API.BLocked_User_Methods.BLOCKED_USER_API)")
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(GetBlockedUserModel.GetBlockedUserSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(GetBlockedUserModel.GetBlockedUserErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func blockUnBlockUser(User_id: Int, Session_Token: String, type: String, blockId: Int, completionBlock: @escaping (_ Success: BlockUnBlockModel.BlockUnBlockSuccessModel?, _ SessionError: BlockUnBlockModel.BlockUnBlockErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.block_id : blockId,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : type,
        ] as [String : Any]
        AF.request(API.BLocked_User_Methods.BLOCKED_USER_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            log.verbose("URL = \(API.BLocked_User_Methods.BLOCKED_USER_API)")
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(BlockUnBlockModel.BlockUnBlockSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(BlockUnBlockModel.BlockUnBlockErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
