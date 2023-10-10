import Foundation

class SearchModel {
    
    struct SearchSuccessModel: Codable {
        
        let apiStatus, apiVersion: String?
        let data: [VideoDetail]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
        
    }
    
    struct SearchErrorModel: Codable {
        
        let apiStatus: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
        
    }
    
}
