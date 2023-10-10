import Foundation

class CashfreeModel {
    
    struct Cashfree_SuccessModal : Codable {
        let api_status : Int?
        let url : String?
        let appId : String?
        let orderId : String?
        let orderAmount : String?
        let orderCurrency : String?
        let orderNote : String?
        let customerName : String?
        let customerEmail : String?
        let customerPhone : String?
        let returnUrl : String?
        let notifyUrl : String?
        let signature : String?
        
        enum CodingKeys: String, CodingKey {
            
            case api_status = "api_status"
            case url = "url"
            case appId = "appId"
            case orderId = "orderId"
            case orderAmount = "orderAmount"
            case orderCurrency = "orderCurrency"
            case orderNote = "orderNote"
            case customerName = "customerName"
            case customerEmail = "customerEmail"
            case customerPhone = "customerPhone"
            case returnUrl = "returnUrl"
            case notifyUrl = "notifyUrl"
            case signature = "signature"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(Int.self, forKey: .api_status)
            url = try values.decodeIfPresent(String.self, forKey: .url)
            appId = try values.decodeIfPresent(String.self, forKey: .appId)
            orderId = try values.decodeIfPresent(String.self, forKey: .orderId)
            orderAmount = try values.decodeIfPresent(String.self, forKey: .orderAmount)
            orderCurrency = try values.decodeIfPresent(String.self, forKey: .orderCurrency)
            orderNote = try values.decodeIfPresent(String.self, forKey: .orderNote)
            customerName = try values.decodeIfPresent(String.self, forKey: .customerName)
            customerEmail = try values.decodeIfPresent(String.self, forKey: .customerEmail)
            customerPhone = try values.decodeIfPresent(String.self, forKey: .customerPhone)
            returnUrl = try values.decodeIfPresent(String.self, forKey: .returnUrl)
            notifyUrl = try values.decodeIfPresent(String.self, forKey: .notifyUrl)
            signature = try values.decodeIfPresent(String.self, forKey: .signature)
        }
        
    }
    
    struct Cashfree_ErrorModal : Codable {
        
        let api_status : String?
        let api_version : String?
        let errors : Errors?
        
        enum CodingKeys: String, CodingKey {
            
            case api_status = "api_status"
            case api_version = "api_version"
            case errors = "errors"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            errors = try values.decodeIfPresent(Errors.self, forKey: .errors)
        }
        
    }

}
