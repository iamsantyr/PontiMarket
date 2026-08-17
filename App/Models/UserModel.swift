import Foundation

struct UserModel: Identifiable, Codable, Equatable, Hashable {

// MARK: - Properties
let id: String
let name: String
let email: String
let profilePictureURL: String?

// MARK: - Initializer
init(id: String, name: String, email: String, profilePictureURL: String? = nil) {
self.id = id
self.name = name
self.email = email
self.profilePictureURL = profilePictureURL
}

// MARK: - Default Profile Image (Optional Helper)
var defaultProfilePictureURL: String {
profilePictureURL ?? "https://via.placeholder.com/150"
}

// MARK: - Equatable & Hashable
static func == (lhs: UserModel, rhs: UserModel) -> Bool {
lhs.id == rhs.id
}

func hash(into hasher: inout Hasher) {
hasher.combine(id)
}
}
