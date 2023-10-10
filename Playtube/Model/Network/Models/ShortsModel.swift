import Foundation

class ShortsModel {
    
    struct ShortsSuccessModel : Codable {
        
        let api_status : String?
        let api_version : String?
        let data : [VideoDetail]?
        let order : String?

        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case data = "data"
            case order = "order"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            data = try values.decodeIfPresent([VideoDetail].self, forKey: .data)
            order = try values.decodeIfPresent(String.self, forKey: .order)
        }

    }
    
    struct ShortsErrorModel : Codable {
        
        let api_status : String?
        let api_text : String?
        let errors : Errors?

        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_text = "api_text"
            case errors = "errors"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_text = try values.decodeIfPresent(String.self, forKey: .api_text)
            errors = try values.decodeIfPresent(Errors.self, forKey: .errors)
        }

    }
    
}

