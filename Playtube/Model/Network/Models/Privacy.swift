import Foundation

struct Privacy : Codable {
	let show_subscriptions_count : String?
	let who_can_message_me : String?
	let who_can_watch_my_videos : String?

	enum CodingKeys: String, CodingKey {

		case show_subscriptions_count = "show_subscriptions_count"
		case who_can_message_me = "who_can_message_me"
		case who_can_watch_my_videos = "who_can_watch_my_videos"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		show_subscriptions_count = try values.decodeIfPresent(String.self, forKey: .show_subscriptions_count)
		who_can_message_me = try values.decodeIfPresent(String.self, forKey: .who_can_message_me)
		who_can_watch_my_videos = try values.decodeIfPresent(String.self, forKey: .who_can_watch_my_videos)
	}

}
