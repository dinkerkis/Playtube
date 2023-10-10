import Foundation

struct ErrorModel : Codable {
    
	let api_status : String?
	let errors : Errors?

	enum CodingKeys: String, CodingKey {

		case api_status = "api_status"
		case errors = "errors"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
		errors = try values.decodeIfPresent(Errors.self, forKey: .errors)
	}

}
