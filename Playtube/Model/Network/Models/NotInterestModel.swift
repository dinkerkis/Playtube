
import Foundation


class NotInterestVideoModel {
    
    struct NotInterestVideoErrorModel: Codable {
        
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct NotInterestVideoSuccessModel: Codable {
        
        let apiStatus, apiVersion: String
        let success_type : String?
        let data: [Datum]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case success_type = "success_type"
            case data
        }
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        
        let id : Int?
        let user_id : Int?
        let video_id : Int?
        let time : Int?
        let video: VideoDetail?
        
        enum CodingKeys: String, CodingKey {
            case id
            case user_id = "user_id"
            case video_id = "video_id"
            case time = "time"
            case video
        }
    }
}
