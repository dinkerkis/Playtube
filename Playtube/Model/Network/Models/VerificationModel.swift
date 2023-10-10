import Foundation

class VerificationModel {
    
    struct VerificationSuccessModel: Codable {
        
        let apiStatus: String
        let apiVersion: String
        let successType: String
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
        
    }
    
    struct VerificationErrorModel: Codable {
        
        let apiStatus: String
        let apiVersion: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
}
