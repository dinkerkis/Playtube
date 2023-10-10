

import Foundation
import Alamofire
import PlaytubeSDK
class ChatManager:NSObject {
    
    static let instance = ChatManager()
    func getChats(User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success: ChatModel.ChatSuccessModel?, _ SessionError: ChatModel.ChatErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : API.Params.Chat_Id
            ] as [String : Any]
        AF.request(API.MESSAGE_Methods.MESSAGE_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("URL = \(API.MESSAGE_Methods.MESSAGE_API + Session_Token)")
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ChatModel.ChatSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                }else if api_status == "400"{
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ChatModel.ChatErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getUserChats(User_id: Int, Session_Token: String, First_id: Int, Last_id: Int, Recipient_id: Int, Limit: Int, completionBlock: @escaping (_ Success: UserChatModel.UserChatSuccessModel?, _ SessionError: UserChatModel.UserChatErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : API.Params.User_Chat_Id,
            API.Params.First_Id : First_id,
            API.Params.Last_Id : Last_id,
            API.Params.Recipient_Id : Recipient_id,
            API.Params.Limit : 10
            ] as [String : Any]
        AF.request(API.MESSAGE_Methods.MESSAGE_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            log.verbose("URL = \(API.MESSAGE_Methods.MESSAGE_API + Session_Token)")
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(UserChatModel.UserChatSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(UserChatModel.UserChatErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
        
    }
    func removeUserChats(User_id: Int, Session_Token: String, Recipient_id: Int, completionBlock: @escaping (_ Success: UserChatRemoveModel.UserChatRemoveSuccessModel?, _ SessionError: UserChatRemoveModel.UserChatRemoveErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : API.Params.User_Clear_Chat_Id,
            API.Params.Recipient_Id : Recipient_id
            ] as [String : Any]
        AF.request(API.MESSAGE_Methods.MESSAGE_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("URL = \(API.MESSAGE_Methods.MESSAGE_API + Session_Token)")
                guard let api_status = Res["api_status"] as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(UserChatRemoveModel.UserChatRemoveSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(UserChatRemoveModel.UserChatRemoveErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func sendUserMessage(User_id: Int, Session_Token: String, Recipient_id: Int, Hash_id: Int, Text: String, completionBlock: @escaping (_ Success: SendMessageModel.SendMessageSuccessModel?, _ SessionError: SendMessageModel.SendMessageErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : API.Params.SEND_MESSAGE_Id,
            API.Params.Recipient_Id : Recipient_id,
            API.Params.Hash_Id : Hash_id,
            API.Params.Text : Text
            ] as [String : Any]
        AF.request(API.MESSAGE_Methods.MESSAGE_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("URL = \(API.MESSAGE_Methods.MESSAGE_API + Session_Token)")
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SendMessageModel.SendMessageSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SendMessageModel.SendMessageErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
