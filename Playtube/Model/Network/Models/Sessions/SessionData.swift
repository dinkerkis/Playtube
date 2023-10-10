import Foundation

struct SessionData : Codable {
    
	let id : Int?
	let session_id : String?
	let user_id : Int?
	let platform : String?
	let platform_details : String?
	let time : String?
	let browser : String?
	let ip_address : String?

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case session_id = "session_id"
		case user_id = "user_id"
		case platform = "platform"
		case platform_details = "platform_details"
		case time = "time"
		case browser = "browser"
		case ip_address = "ip_address"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		session_id = try values.decodeIfPresent(String.self, forKey: .session_id)
		user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
		platform = try values.decodeIfPresent(String.self, forKey: .platform)
		platform_details = try values.decodeIfPresent(String.self, forKey: .platform_details)
		time = try values.decodeIfPresent(String.self, forKey: .time)
		browser = try values.decodeIfPresent(String.self, forKey: .browser)
		ip_address = try values.decodeIfPresent(String.self, forKey: .ip_address)
	}

}
