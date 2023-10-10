import Foundation

class LibraryModel {
    
    struct LibrarySuccessModel: Codable {
        
        let apiStatus, apiVersion, successType: String
        let data: [VideoDetail]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
        
    }
    struct LibraryErrorModel: Codable {
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
    }
    
}


class RecentlyWatchModel {
    
    struct RecentlyWatchSuccessModel: Codable {
        
        let apiStatus, apiVersion, successType: String
        let data: [VideoDetail]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
        
    }
    
    struct RecentlyWatchErrorModel: Codable {
        
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }
    
}


class SubscriptionModel {
    
    struct SubscriptionSuccessModel: Codable {
        let api_status : String?
        let api_version : String?
        let data : [Owner]?

        enum CodingKeys: String, CodingKey {

            case api_status = "api_status"
            case api_version = "api_version"
            case data = "data"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            data = try values.decodeIfPresent([Owner].self, forKey: .data)
        }
    }
    
    struct SubscriptionErrorModel: Codable {
                
        let api_status : String?
        let api_version : String?
        let errors : Errors?
        
        enum CodingKeys: String, CodingKey {
            
            case api_status = "api_status"
            case api_version = "api_version"
            case errors = "errors"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            errors = try values.decodeIfPresent(Errors.self, forKey: .errors)
        }
        
    }
    
}

class SubscribedChannelVideosModel {
    
    struct SubscribedChannelVideosSuccessModel: Codable {
        
        let apiStatus, apiVersion: String?
        let data: [VideoDetail]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
        
    }
    
    struct SubscribedChannelVideosErrorModel: Codable {
        
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
}
