import Foundation

class PlayVideoModel {
    
    struct PlayVideoSuccessModel: Codable {
        
        let api_status : String?
        let api_version : String?
        let data: VideoDetail?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case data = "data"
        }
        
    }
    
    struct PlayVideoErrorModel: Codable {
        
        let api_status: String?
        let api_version: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case errors = "errors"
        }
        
    }
    
    struct Errors: Codable {
        
        let error_id: String?
        let error_text: String?
        
        enum CodingKeys: String, CodingKey {
            case error_id = "error_id"
            case error_text = "error_text"
        }
        
    }
    
}

class SubscribeModel {
    
    struct SubscribeSuccessModel: Codable {
        
        let api_status: String?
        let api_version: String?
        let code: Int?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case code = "code"
        }
        
    }
    
    struct SubscribeErrorModel: Codable {
        
        let api_status: String?
        let api_version: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case errors = "errors"
        }
        
    }
    
}

class LikeDislikeModel {
    
    struct LikeDislikeSuccessModel: Codable {
        
        let api_status: String?
        let api_version: String?
        let success_type: String?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case success_type = "success_type"
        }
        
    }
    
    struct LikeDislikeErrorModel: Codable {
        
        let api_status: String?
        let api_version: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case errors = "errors"
        }
        
    }
    
}
