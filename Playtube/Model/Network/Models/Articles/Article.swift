import Foundation

struct Article : Codable {
	let id : Int?
	let title : String?
	let description : String?
	let category : String?
	let image : String?
	let text : String?
	let tags : String?
	let time : String?
	let user_id : Int?
	let active : Int?
	let views : String?
	let shared : Int?
	let orginal_text : String?
	let url : String?
	let time_format : String?
	let text_time : String?
	let user_data : Owner?
	let comments_count : Int?
	let likes : Int?
	let dislikes : Int?
	let liked : Int?
	let disliked : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case title = "title"
		case description = "description"
		case category = "category"
		case image = "image"
		case text = "text"
		case tags = "tags"
		case time = "time"
		case user_id = "user_id"
		case active = "active"
		case views = "views"
		case shared = "shared"
		case orginal_text = "orginal_text"
		case url = "url"
		case time_format = "time_format"
		case text_time = "text_time"
		case user_data = "user_data"
		case comments_count = "comments_count"
		case likes = "likes"
		case dislikes = "dislikes"
		case liked = "liked"
		case disliked = "disliked"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		category = try values.decodeIfPresent(String.self, forKey: .category)
		image = try values.decodeIfPresent(String.self, forKey: .image)
		text = try values.decodeIfPresent(String.self, forKey: .text)
		tags = try values.decodeIfPresent(String.self, forKey: .tags)
		time = try values.decodeIfPresent(String.self, forKey: .time)
		user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
		active = try values.decodeIfPresent(Int.self, forKey: .active)
		views = try values.decodeIfPresent(String.self, forKey: .views)
		shared = try values.decodeIfPresent(Int.self, forKey: .shared)
		orginal_text = try values.decodeIfPresent(String.self, forKey: .orginal_text)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		time_format = try values.decodeIfPresent(String.self, forKey: .time_format)
		text_time = try values.decodeIfPresent(String.self, forKey: .text_time)
		user_data = try values.decodeIfPresent(Owner.self, forKey: .user_data)
		comments_count = try values.decodeIfPresent(Int.self, forKey: .comments_count)
		likes = try values.decodeIfPresent(Int.self, forKey: .likes)
		dislikes = try values.decodeIfPresent(Int.self, forKey: .dislikes)
		liked = try values.decodeIfPresent(Int.self, forKey: .liked)
		disliked = try values.decodeIfPresent(Int.self, forKey: .disliked)
	}

}
