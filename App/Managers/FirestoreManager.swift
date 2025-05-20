import FirebaseFirestore
import Foundation

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    private init() {} // Patrón Singleton

    func saveUser(_ user: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
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
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])))
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

    // Cambiado: Agregar descripción
    func addProduct(name: String, description: String, price: Double, userEmail: String, completion: @escaping (Bool) -> Void) {
        let product = [
            "name": name,
            "description": description,
            "price": price,
            "userEmail": userEmail
        ] as [String: Any]

        db.collection("products").addDocument(data: product) { error in
            completion(error == nil)
        }
    }

    // Cambiado: Traer descripción
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

                return Product(name: name, description: description, price: price, userEmail: userEmail)
            }
            completion(products)
        }
    }
}

//Cambiado: Modelo actualizado
struct Product: Codable {
    let name: String
    let description: String
    let price: Double
    let userEmail: String
}
