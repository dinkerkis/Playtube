import Foundation
import Alamofire
import PlaytubeSDK

class SearchManager: NSObject {
    
    static let instance = SearchManager()
    
    func searchVideo(User_id: Int, Session_Token: String, SearchText: String, filterParam: String, completionBlock: @escaping (_ Success: SearchModel.SearchSuccessModel?, _ SessionError: SearchModel.SearchErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            "date": filterParam
            ] as [String : Any]
        print(API.SEARCH_VIDEOS_Methods.SEARCH_VIDEOS_API + "\(SearchText)")
        AF.request(API.SEARCH_VIDEOS_Methods.SEARCH_VIDEOS_API + "\(SearchText)", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SearchModel.SearchSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SearchModel.SearchErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
        
    }
    
}
