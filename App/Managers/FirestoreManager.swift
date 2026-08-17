import FirebaseFirestore
import Foundation

class FirestoreManager {
static let shared = FirestoreManager()
private let db = Firestore.firestore()

private init() {} // Singleton

// MARK: - Guardar usuario en Firestore
func saveUser(_ user: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
let userData: [String: Any] = [
"id": user.id,
"name": user.name,
"email": user.email.lowercased(),
"profilePictureURL": user.profilePictureURL ?? ""
]

db.collection("users").document(user.id).setData(userData) { error in
if let error = error {
completion(.failure(error))
} else {
completion(.success(()))
}
}
}

// MARK: - Obtener usuario por ID
func fetchUser(userId: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
db.collection("users").document(userId).getDocument { snapshot, error in
if let error = error {
completion(.failure(error))
return
}

guard let data = snapshot?.data(),
let id = data["id"] as? String,
let name = data["name"] as? String,
let email = data["email"] as? String else {
completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado."])))
return
}

let user = UserModel(
id: id,
name: name,
email: email,
profilePictureURL: data["profilePictureURL"] as? String
)

completion(.success(user))
}
}

// MARK: - Agregar producto (ahora incluye imageUrl)
func addProduct(name: String, description: String, price: Double, userEmail: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
var product: [String: Any] = [
"name": name,
"description": description,
"price": price,
"userEmail": userEmail.lowercased()
]

if let imageUrl = imageUrl {
product["imageUrl"] = imageUrl
}

db.collection("products").addDocument(data: product) { error in
completion(error == nil)
}
}

// MARK: - Obtener productos
func fetchProducts(completion: @escaping ([Product]) -> Void) {
db.collection("products").getDocuments { snapshot, error in
guard let documents = snapshot?.documents, error == nil else {
completion([])
return
}

let products: [Product] = documents.compactMap { doc in
let data = doc.data()
guard let name = data["name"] as? String,
let price = data["price"] as? Double,
let userEmail = data["userEmail"] as? String else {
return nil
}

let description = data["description"] as? String ?? ""
let imageUrl = data["imageUrl"] as? String

return Product(name: name, description: description, price: price, userEmail: userEmail, imageUrl: imageUrl)
}
completion(products)
}
}

// MARK: - Verificar si un email ya existe en Firestore
func doesEmailExist(_ email: String, completion: @escaping (Bool) -> Void) {
let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

db.collection("users")
.whereField("email", isEqualTo: trimmedEmail)
.limit(to: 1)
.getDocuments { snapshot, error in
if let error = error {
print("❌ Error verificando email en Firestore: \(error.localizedDescription)")
completion(false)
return
}

if let docs = snapshot?.documents, !docs.isEmpty {
print("✅ Email encontrado en Firestore.")
completion(true)
} else {
print("⚠️ Email no encontrado en Firestore.")
completion(false)
}
}
}
}

// MARK: - Modelo de producto actualizado
struct Product: Codable {
let name: String
let description: String
let price: Double
let userEmail: String
let imageUrl: String?
}
