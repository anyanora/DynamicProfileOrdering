import Foundation

struct Profile: Codable {
    let id: Int
    let name: String
    let gender: String
    let photo: String?
    let about: String?
    let school: String?
    let job: String?
    let location: String?
    let age: Int?
}

struct ProfilesResponse: Codable {
    let users: [Profile]
}

