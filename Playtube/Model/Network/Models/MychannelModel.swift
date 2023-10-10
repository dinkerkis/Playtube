import Foundation

class MychannelModel {
    
    class ChangePasswordModel {
        
        struct ChangePassordSuccessModel: Codable {
            
            let apiStatus, apiVersion, message: String?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case message
            }
            
        }
        
        struct ChangePassordErrorModel: Codable {
            
            let apiStatus, apiVersion: String?
            let errors: Errors?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case errors
            }
            
        }
        
    }
    
    class UpdateMyChannelModel {
        
        struct UpdateChannelSuccessModel: Codable {
            
            let apiStatus, apiVersion, message: String?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case message
            }
            
        }
        
        struct UpdateChannelErrorModel: Codable {
            
            let apiStatus, apiVersion: String?
            let errors: Errors?
            let status: Int?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case errors, status
            }
            
        }
        
    }
    
    class GetChannelInfoModel {
        
        struct GetChannelInfoSuccessModel: Codable {
            let apiStatus, apiVersion: String?
            let data: Owner?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case data
            }
            
        }
        
        struct GetChannelInfoErrorModel: Codable {
            let apiStatus: String?
            let errors: Errors?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case errors
            }
        }
        
    }
    
    class ChannelVideos {
        
        struct ChannelVideosSUccessModel: Codable {
            
            let apiStatus, apiVersion: String
            let data: [VideoDetail]?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case data
            }
            
        }
        
        struct ChannelVideosErrorModel: Codable {
            
            let apiStatus, apiVersion: String?
            let errors: Errors?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case errors
            }
            
        }
        
    }
    
}

class DeleteHistoryModel {
    
    
    struct DeleteHistorySuccessModel: Codable {
        
        let apiStatus, apiVersion, successType, message: String
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
        
    }
    
    struct DeleteHistoryErrorModel: Codable {
        
        let apiStatus, apiVersion: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
}
