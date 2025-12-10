import Foundation

struct ProfileConfiguration: Codable {
    let fieldOrder: [String]
    
    enum CodingKeys: String, CodingKey {
        case fieldOrder = "field_order"
    }
}

struct ProfileConfigurationResponse: Codable {
    let configuration: ProfileConfiguration
}

