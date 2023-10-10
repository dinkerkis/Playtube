import Foundation

class TrendingModel {
    
    struct TrendingSuccessModel: Codable {
        
        let api_status : String?
        let api_version : String?
        let data : [VideoDetail]?
        
        enum CodingKeys: String, CodingKey {

            case api_status = "api_status"
            case api_version = "api_version"
            case data = "data"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            data = try values.decodeIfPresent([VideoDetail].self, forKey: .data)
        }
    }
    
    struct TrendingErrorModel: Codable {
        
        let api_status: String?
        let api_text: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_text = "api_text"
            case errors = "errors"
        }
        
    }
    
}
