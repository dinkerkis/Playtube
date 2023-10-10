import Foundation

class LoginModel {
    
    struct UserErrorModel: Codable {
        
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
    struct UserSuccessModel: Codable {
        
        let apiStatus, apiVersion: String?
        let data: DataClass?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
        
    }
    
    struct DataClass: Codable {
        
        let sessionID, message: String?
        let userID: Int?
        let cookie: String?
        
        enum CodingKeys: String, CodingKey {
            case sessionID = "session_id"
            case message
            case userID = "user_id"
            case cookie
        }
        
    }
    
}
