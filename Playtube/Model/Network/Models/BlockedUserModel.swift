

import Foundation
class GetBlockedUserModel{
    struct GetBlockedUserSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let users: [Owner]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case users
        }
    }
    
    // MARK: - User
//    struct User: Codable {
//        let id: Int?
//        let username, email, firstName, lastName: String?
//        let gender, language: String?
//        let avatar, cover: String?
//        let about, google, facebook, twitter: String?
//        let verified, isPro: Int?
//        let url: String?
//        
//        enum CodingKeys: String, CodingKey {
//            case id, username, email
//            case firstName = "first_name"
//            case lastName = "last_name"
//            case gender, language, avatar, cover, about, google, facebook, twitter, verified
//            case isPro = "is_pro"
//            case url
//        }
//    }
    struct GetBlockedUserErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }

}

class BlockUnBlockModel {
    
    struct BlockUnBlockSuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String?
        let code: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message, code
        }
    }
    struct BlockUnBlockErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }

}
