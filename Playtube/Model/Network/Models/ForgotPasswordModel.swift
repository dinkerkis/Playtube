import Foundation

class ForgotPasswordModel {
    
    struct ForgotPasswordSuccessModel: Codable {
        
        let apiStatus: String?
        let apiVersion: String?
        let data: DataClass?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
        
    }
    
    struct DataClass: Codable {
        let email: String?
        let message: String?
    }
    
    struct ForgotPasswordErrorModel: Codable {
        
        let apiStatus: String?
        let apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
}
