import Foundation
import UIKit

struct CloudinaryUploader {
static func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
guard let imageData = image.jpegData(compressionQuality: 0.8) else {
completion(.failure(NSError(domain: "CloudinaryUploader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error al convertir la imagen."])))
return
}

let url = URL(string: "https://api.cloudinary.com/v1_1/dv4hjige5/image/upload")!
var request = URLRequest(url: url)
request.httpMethod = "POST"

let boundary = UUID().uuidString
request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

var body = Data()

// Añadir upload_preset
body.append("--\(boundary)\r\n".data(using: .utf8)!)
body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
body.append("PontiMarket_unsigned\r\n".data(using: .utf8)!)

// Añadir folder
body.append("--\(boundary)\r\n".data(using: .utf8)!)
body.append("Content-Disposition: form-data; name=\"folder\"\r\n\r\n".data(using: .utf8)!)
body.append("PontiMarket\r\n".data(using: .utf8)!)

// Añadir imagen
body.append("--\(boundary)\r\n".data(using: .utf8)!)
body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
body.append(imageData)
body.append("\r\n".data(using: .utf8)!)

body.append("--\(boundary)--\r\n".data(using: .utf8)!)
request.httpBody = body

URLSession.shared.dataTask(with: request) { data, response, error in
if let error = error {
completion(.failure(error))
return
}

guard let data = data,
let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
let url = json["secure_url"] as? String else {
completion(.failure(NSError(domain: "CloudinaryUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida."])))
return
}

completion(.success(url))
}.resume()
}
}
