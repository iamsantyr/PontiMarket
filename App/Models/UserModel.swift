import Foundation

struct UserModel: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let profilePictureURL: String?

    init(id: String, name: String, email: String, profilePictureURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
}
