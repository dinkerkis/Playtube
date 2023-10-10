import Foundation

class ArticlesModel {
    
    struct ArticlesSuccessModel: Codable {
        
        let api_status : String?
        let api_version : String?
        let success_type : String?
        let data : [Article]?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case success_type = "success_type"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            success_type = try values.decodeIfPresent(String.self, forKey: .success_type)
            data = try values.decodeIfPresent([Article].self, forKey: .data)
        }
        
    }
    
    struct ArticlesErrorModel: Codable {
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
    }
    
}

class ArticlesCommentModel {
   
    struct ArticlesCommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String
        let data: [Comment]?

        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
    }
    
    struct ArticlesCommentErrorModel: Codable {
        let apiStatus: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }

}

class AddArticleCommentModel {
    
    struct AddArticleCommentSuccessModel: Codable {
        
        let apiStatus, apiVersion, successType, message: String?
        let id: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message, id
        }
        
    }

    struct AddArticleCommentErrorModel: Codable {
        
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }

}
