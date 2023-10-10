import Foundation

struct Video_ad : Codable {
	let id : Int?
	let ad_link : String?
	let name : String?
	let ad_media : String?
	let ad_image : String?
	let skip_seconds : Int?
	let vast_type : String?
	let vast_xml_link : String?
	let views : Int?
	let clicks : Int?
	let active : Int?
	let user_id : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case ad_link = "ad_link"
		case name = "name"
		case ad_media = "ad_media"
		case ad_image = "ad_image"
		case skip_seconds = "skip_seconds"
		case vast_type = "vast_type"
		case vast_xml_link = "vast_xml_link"
		case views = "views"
		case clicks = "clicks"
		case active = "active"
		case user_id = "user_id"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		ad_link = try values.decodeIfPresent(String.self, forKey: .ad_link)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		ad_media = try values.decodeIfPresent(String.self, forKey: .ad_media)
		ad_image = try values.decodeIfPresent(String.self, forKey: .ad_image)
		skip_seconds = try values.decodeIfPresent(Int.self, forKey: .skip_seconds)
		vast_type = try values.decodeIfPresent(String.self, forKey: .vast_type)
		vast_xml_link = try values.decodeIfPresent(String.self, forKey: .vast_xml_link)
		views = try values.decodeIfPresent(Int.self, forKey: .views)
		clicks = try values.decodeIfPresent(Int.self, forKey: .clicks)
		active = try values.decodeIfPresent(Int.self, forKey: .active)
		user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
	}

}
