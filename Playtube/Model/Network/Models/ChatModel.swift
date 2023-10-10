import Foundation

class ChatModel {
    
    struct ChatSuccessModel: Codable {
        
       let apiStatus, apiVersion, successType: String
    let data: [Datum]?

        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
    }
    struct ChatErrorModel: Codable {
        let apiStatus: String?
        let errors: Errors?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
          
            case errors
        }
    }
    

    // MARK: - Datum
    struct Datum: Codable {
        let id, userOne, userTwo, time: Int?
        let textTime: String?
        let user: User?
        let getCountSeen: Int?
        let getLastMessage: GetLastMessage?

        enum CodingKeys: String, CodingKey {
            case id
            case userOne = "user_one"
            case userTwo = "user_two"
            case time
            case textTime = "text_time"
            case user
            case getCountSeen = "get_count_seen"
            case getLastMessage = "get_last_message"
        }
    }

    // MARK: - GetLastMessage
    struct GetLastMessage: Codable {
        let id, fromID, toID: Int?
        let text: String?
        let seen, time, fromDeleted, toDeleted: Int?
        let textTime: String?

        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text, seen, time
            case fromDeleted = "from_deleted"
            case toDeleted = "to_deleted"
            case textTime = "text_time"
        }
    }

    // MARK: - User
    struct User: Codable {
        let id: Int?
        let username, email, ipAddress, firstName: String?
        let lastName, gender, emailCode, deviceID: String?
        let language: String?
        var avatar, cover: String?
        let src: String?
        let countryID, age: Int?
        let about, google, facebook, twitter: String?
        let instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let isPro, imports, uploads: Int?
        let wallet: Double?
        let balance: String?
        let videoMon, ageChanged: Int?
        let donationPaypalEmail, userUploadLimit: String?
        let twoFactor: Int?
        let lastMonth: String?
        let activeTime: Int?
        let activeExpire, phoneNumber, address, city: String?
        let state: String?
        let zip: Int?
        let subscriberPrice: String?
        let monetization: Int?
        let newEmail: String?
        let favCategory: [String]?
        let totalAds, suspendUpload, suspendImport: Int?
        let paystackRef, conversationID: String?
        let pointDayExpire, points, dailyPoints: Int?
        let name, exCover: String?
        let url: String?
        let aboutDecoded: String?
        let fullCover: String?
        let balanceOr, nameV, countryName, genderText: String?
        let amISubscribed: Int?
        let subscribeCount, textTime: String?

        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case firstName = "first_name"
            case lastName = "last_name"
            case gender
            case emailCode = "email_code"
            case deviceID = "device_id"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram, active, admin, verified
            case lastActive = "last_active"
            case registered
            case isPro = "is_pro"
            case imports, uploads, wallet, balance
            case videoMon = "video_mon"
            case ageChanged = "age_changed"
            case donationPaypalEmail = "donation_paypal_email"
            case userUploadLimit = "user_upload_limit"
            case twoFactor = "two_factor"
            case lastMonth = "last_month"
            case activeTime = "active_time"
            case activeExpire = "active_expire"
            case phoneNumber = "phone_number"
            case address, city, state, zip
            case subscriberPrice = "subscriber_price"
            case monetization
            case newEmail = "new_email"
            case favCategory = "fav_category"
            case totalAds = "total_ads"
            case suspendUpload = "suspend_upload"
            case suspendImport = "suspend_import"
            case paystackRef = "paystack_ref"
            case conversationID = "ConversationId"
            case pointDayExpire = "point_day_expire"
            case points
            case dailyPoints = "daily_points"
            case name
            case exCover = "ex_cover"
            case url
            case aboutDecoded = "about_decoded"
            case fullCover = "full_cover"
            case balanceOr = "balance_or"
            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
            case amISubscribed = "am_i_subscribed"
            case subscribeCount = "subscribe_count"
            case textTime = "text_time"
        }
    }

}
class UserChatModel {
    
    struct UserChatSuccessModel: Codable {
        
        let apiStatus, apiVersion, successType: String
         let data: DataClass?

         enum CodingKeys: String, CodingKey {
             case apiStatus = "api_status"
             case apiVersion = "api_version"
             case successType = "success_type"
             case data
         }
        
    }
    
    struct UserChatErrorModel: Codable {
        let apiStatus: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
         
            case errors
        }
    }

    // MARK: - DataClass
    struct DataClass: Codable {
        let userData: UserData?
        let messages: [Message]?

        enum CodingKeys: String, CodingKey {
            case userData = "user_data"
            case messages
        }
    }
    
    // MARK: - Message
    struct Message: Codable {
        let id, fromID, toID: Int?
        let text: String?
        let seen, time, fromDeleted, toDeleted: Int?
        let textTime, position: String?

        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text, seen, time
            case fromDeleted = "from_deleted"
            case toDeleted = "to_deleted"
            case textTime = "text_time"
            case position
        }
    }
    
    enum Position: String, Codable {
        case positionLeft = "left"
        case positionRight = "right"
    }
    

    // MARK: - UserData
    struct UserData: Codable {
        let id: Int?
        let username, email, ipAddress, firstName: String?
        let lastName, gender, emailCode, deviceID: String?
        let language: String?
        let avatar, cover: String?
        let src: String?
        let countryID, age: Int?
        let about, google, facebook, twitter: String?
        let instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let isPro, imports, uploads: Int?
        let wallet: Double?
        let balance: String?
        let videoMon, ageChanged: Int?
        let donationPaypalEmail, userUploadLimit: String?
        let twoFactor: Int?
        let lastMonth: String?
        let activeTime: Int?
        let activeExpire, phoneNumber, address, city: String?
        let state: String?
        let zip: Int?
        let subscriberPrice: String?
        let monetization: Int?
        let newEmail: String?
        let favCategory: [String]?
        let totalAds, suspendUpload, suspendImport: Int?
        let paystackRef, conversationID: String?
        let pointDayExpire, points, dailyPoints: Int?
        let name, exCover: String?
        let url: String?
        let aboutDecoded: String?
        let fullCover: String?
        let balanceOr, nameV, countryName, genderText: String?
        let amISubscribed: Int?
        let subscribeCount: String?
        let isSubscribedToChannel: Int?
        let textTime: String?

        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case firstName = "first_name"
            case lastName = "last_name"
            case gender
            case emailCode = "email_code"
            case deviceID = "device_id"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram, active, admin, verified
            case lastActive = "last_active"
            case registered
            case isPro = "is_pro"
            case imports, uploads, wallet, balance
            case videoMon = "video_mon"
            case ageChanged = "age_changed"
            case donationPaypalEmail = "donation_paypal_email"
            case userUploadLimit = "user_upload_limit"
            case twoFactor = "two_factor"
            case lastMonth = "last_month"
            case activeTime = "active_time"
            case activeExpire = "active_expire"
            case phoneNumber = "phone_number"
            case address, city, state, zip
            case subscriberPrice = "subscriber_price"
            case monetization
            case newEmail = "new_email"
            case favCategory = "fav_category"
            case totalAds = "total_ads"
            case suspendUpload = "suspend_upload"
            case suspendImport = "suspend_import"
            case paystackRef = "paystack_ref"
            case conversationID = "ConversationId"
            case pointDayExpire = "point_day_expire"
            case points
            case dailyPoints = "daily_points"
            case name
            case exCover = "ex_cover"
            case url
            case aboutDecoded = "about_decoded"
            case fullCover = "full_cover"
            case balanceOr = "balance_or"
            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
            case amISubscribed = "am_i_subscribed"
            case subscribeCount = "subscribe_count"
            case isSubscribedToChannel = "is_subscribed_to_channel"
            case textTime = "text_time"
        }
    }

}
class UserChatRemoveModel{
    struct UserChatRemoveSuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
    }

    
    struct UserChatRemoveErrorModel: Codable {
        let apiStatus: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }


}
class SendMessageModel{
    struct SendMessageSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let data: DataClass?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
    }
    struct SendMessageErrorModel: Codable {
        let apiStatus, apiVersion: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct DataClass: Codable {
        let id, fromID, toID: Int?
        let text: String?
        let seen, time, fromDeleted, toDeleted: Int?
        let textTime, hashID: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text, seen, time
            case fromDeleted = "from_deleted"
            case toDeleted = "to_deleted"
            case textTime = "text_time"
            case hashID = "hash_id"
        }
    }

}
