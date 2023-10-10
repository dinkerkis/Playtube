import Foundation

struct Errors : Codable {
    
	let error_id : String?
	let error_text : String?

	enum CodingKeys: String, CodingKey {

		case error_id = "error_id"
		case error_text = "error_text"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		error_id = try values.decodeIfPresent(String.self, forKey: .error_id)
		error_text = try values.decodeIfPresent(String.self, forKey: .error_text)
	}

}
