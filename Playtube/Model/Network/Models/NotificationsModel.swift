import Foundation

class NotificationsModel {
    
    struct NotificationsErrorModel: Codable {
        
        let apiStatus: String?
        let apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }
    
    struct NotificationsSuccessModel: Codable {
        
        let apiStatus: String?
        let apiVersion: String?
        let notifications: [Notification]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case notifications
        }
        
    }
    
    struct Notification: Codable {
        
        let id: Int?
        let userData: Owner?
        let video: VIDEOUnion?
        let title: String?
        let url: String?
        let time, icon: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case userData = "USER_DATA"
            case video = "VIDEO"
            case title = "TITLE"
            case url = "URL"
            case time = "TIME"
            case icon = "ICON"
        }
        
    }
    
    enum VIDEOUnion: Codable {
        
        case string(String)
        case videoClass(VideoDetail)
        
        var stringValue : String? {
            guard case let .string(value) = self else { return nil }
            return value
        }
        
        var videoClass : VideoDetail? {
            guard case let .videoClass(value) = self else { return nil }
            return value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(String.self) {
                self = .string(x)
                return
            }
            if let x = try? container.decode(VideoDetail.self) {
                self = .videoClass(x)
                return
            }
            throw DecodingError.typeMismatch(VIDEOUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for VIDEOUnion"))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let x):
                try container.encode(x)
            case .videoClass(let x):
                try container.encode(x)
            }
        }
        
    }
    
}
