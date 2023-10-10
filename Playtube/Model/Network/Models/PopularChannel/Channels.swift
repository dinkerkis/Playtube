import Foundation

struct Channels : Codable {
    
	let is_subscribed_to_channel : Int?
	let user_data : Owner?
	let views : ViewsCount?
	let count : ViewsCount?
	let subscribers_count : SubscribersCount?
	let active_time : String?

	enum CodingKeys: String, CodingKey {

		case is_subscribed_to_channel = "is_subscribed_to_channel"
		case user_data = "user_data"
		case views = "views"
		case count = "count"
		case subscribers_count = "subscribers_count"
		case active_time = "active_time"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		is_subscribed_to_channel = try values.decodeIfPresent(Int.self, forKey: .is_subscribed_to_channel)
		user_data = try values.decodeIfPresent(Owner.self, forKey: .user_data)
		views = try values.decodeIfPresent(ViewsCount.self, forKey: .views)
		count = try values.decodeIfPresent(ViewsCount.self, forKey: .count)
		subscribers_count = try values.decodeIfPresent(SubscribersCount.self, forKey: .subscribers_count)
		active_time = try values.decodeIfPresent(String.self, forKey: .active_time)
	}

}

enum SubscribersCount: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(SubscribersCount.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SubscribersCount"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

enum ViewsCount: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(SubscribersCount.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SubscribersCount"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
