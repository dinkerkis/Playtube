import Foundation
import Alamofire
import PlaytubeSDK

class ArticlesManager: NSObject {
    
    static let instance = ArticlesManager()
    
    func getTrendingData(url: String, cat_id: String, User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success: ArticlesModel.ArticlesSuccessModel?, _ SessionError: ArticlesModel.ArticlesErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            "category_id": cat_id
        ] as [String : Any]
        print("URL :=> ", url)
        print("PARAM :=> ",params)
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            log.verbose("URL = \(API.Trending_Methods.TRENDING_VIDEOS_API + Session_Token)")
            if let Res = response.value as? [String: Any] {
                log.verbose("URL = \(API.Trending_Methods.TRENDING_VIDEOS_API + Session_Token)")
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ArticlesModel.ArticlesSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ArticlesModel.ArticlesErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getArticlesComments(User_id: Int, Session_Token: String, Limit: Int, Post_id: Int, completionBlock: @escaping (_ Success: ArticlesCommentModel.ArticlesCommentSuccessModel?, _ SessionError: ArticlesCommentModel.ArticlesCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Post_Id : Post_id,
            API.Params.Limit : Limit,
            API.Params.Comment_Type : API.Params.Fetch_Comment
            ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print("URL = \(API.COMMENT_Methods.COMMENT_API)")
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ArticlesCommentModel.ArticlesCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ArticlesCommentModel.ArticlesCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func addArtilcesComments(User_id: Int, Session_Token: String, Post_id: Int, Comment_Text: String, completionBlock: @escaping (_ Success: AddArticleCommentModel.AddArticleCommentSuccessModel?, _ SessionError: AddArticleCommentModel.AddArticleCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Text : Comment_Text,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Post_Id : Post_id,
            API.Params.Comment_Type : API.Params.Add_Comment
            ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddArticleCommentModel.AddArticleCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddArticleCommentModel.AddArticleCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func addArticleCommentReply(article_id: Int, Comment_Id: Int, Comment_Text: String, completionBlock: @escaping (_ Success: CommentReplyModel.CommentReplySuccessModel?, _ SessionError: CommentReplyModel.CommentReplyErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Text: Comment_Text,
            API.Params.user_id: AppInstance.instance.userProfile?.data?.id ?? "",
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type: "reply",
            API.Params.Comment_Id: Comment_Id,
            API.Params.Post_Id: article_id
            ] as [String: Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CommentReplyModel.CommentReplySuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CommentReplyModel.CommentReplyErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func likeDislikeArticles(User_id: Int, Session_Token: String, Artilce_id: Int, Like_Type: String, completionBlock: @escaping (_ Success: LikeDislikeModel.LikeDislikeSuccessModel?, _ SessionError: LikeDislikeModel.LikeDislikeErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Action : Like_Type,
            API.Params.Video_id : Artilce_id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            ] as [String : Any]
        AF.request(API.PLAY_VIDEO_Methods.LIKE_DISLIKE_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeDislikeModel.LikeDislikeSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeDislikeModel.LikeDislikeErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }

    func likeArticleComments(User_id: Int, Session_Token: String, Type: String, Comment_Id: Int, completionBlock: @escaping (_ Success: LikeCommentModel.LikeCommentSuccessModel?, _ SessionError: LikeCommentModel.LikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Comment_Id: Comment_Id,
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type: Type
            ] as [String: Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeCommentModel.LikeCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeCommentModel.LikeCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func dislikeArticlesComments(User_id: Int, Session_Token: String, Type: String, Comment_Id: Int, completionBlock: @escaping (_ Success: DislikeCommentModel.DislikeCommentSuccessModel?, _ SessionError: DislikeCommentModel.DislikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Comment_Id : Comment_Id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : Type
            ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DislikeCommentModel.DislikeCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DislikeCommentModel.DislikeCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
