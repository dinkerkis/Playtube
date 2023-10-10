
import Foundation
class MonetizationModel{
    struct MonetizationSuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
    }
    struct MonetizationErrorModel: Codable {
        let apiStatus, apiVersion: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }

}
