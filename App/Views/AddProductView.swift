import SwiftUI
import FirebaseAuth

struct AddProductView: View {
@Environment(\.presentationMode) var presentationMode

@State private var title = ""
@State private var description = ""
@State private var price = ""

@State private var showImagePicker = false
@State private var productImage: UIImage?

@State private var isLoading = false
@State private var showSuccessAlert = false
@State private var showErrorAlert = false
@State private var errorMessage = ""

var body: some View {
NavigationView {
Form {
Section(header: Text("Foto del producto")) {
if let image = productImage {
Image(uiImage: image)
.resizable()
.scaledToFit()
.frame(height: 200)
.cornerRadius(10)
}

Button(action: {
showImagePicker = true
}) {
HStack {
Image(systemName: "photo.badge.plus")
Text(productImage == nil ? "Subir imagen" : "Cambiar imagen")
}
}
}

Section(header: Text("Información del producto")) {
TextField("Nombre", text: $title)
TextField("Descripción", text: $description)
TextField("Precio", text: $price)
.keyboardType(.decimalPad)
.onChange(of: price) {
let filtered = price.filter { "0123456789.".contains($0) }
let dotCount = filtered.filter { $0 == "." }.count

if dotCount > 1 {
let firstDotIndex = filtered.firstIndex(of: ".")!
let cleaned = filtered.prefix(upTo: filtered.index(after: firstDotIndex)) +
filtered[filtered.index(after: firstDotIndex)...].replacingOccurrences(of: ".", with: "")
price = String(cleaned)
} else if filtered != price {
price = filtered
}
}
}

Section {
Button(action: {
saveProductToCloudinary()
}) {
if isLoading {
HStack {
ProgressView()
Text("Guardando...")
}
} else {
Text("Guardar")
}
}
.disabled(!isFormValid || isLoading)
}
}
.navigationTitle("Nuevo producto")
.navigationBarItems(trailing: Button("Cancelar") {
presentationMode.wrappedValue.dismiss()
})
.sheet(isPresented: $showImagePicker) {
ImagePicker(image: $productImage, sourceType: .camera)
}
.alert("¡Producto guardado!", isPresented: $showSuccessAlert) {
Button("OK") {
presentationMode.wrappedValue.dismiss()
}
}
.alert("Error", isPresented: $showErrorAlert) {
Button("OK", role: .cancel) { }
} message: {
Text(errorMessage)
}
}
}

var isFormValid: Bool {
return !title.isEmpty &&
!description.isEmpty &&
!price.isEmpty &&
productImage != nil
}

// MARK: - Subir imagen a Cloudinary
func saveProductToCloudinary() {
guard let image = productImage else {
errorMessage = "No se ha seleccionado una imagen."
showErrorAlert = true
return
}

guard let imageData = image.jpegData(compressionQuality: 0.8) else {
errorMessage = "No se pudo convertir la imagen."
showErrorAlert = true
return
}

isLoading = true

let url = URL(string: "https://api.cloudinary.com/v1_1/dv4hjjge5/image/upload")!
let uploadPreset = "PontiMarket_unsigned"
let boundary = UUID().uuidString

var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

var body = Data()

body.append("--\(boundary)\r\n")
body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
body.append("\(uploadPreset)\r\n")

body.append("--\(boundary)\r\n")
body.append("Content-Disposition: form-data; name=\"folder\"\r\n\r\n")
body.append("PontiMarket\r\n")

body.append("--\(boundary)\r\n")
body.append("Content-Disposition: form-data; name=\"file\"; filename=\"product.jpg\"\r\n")
body.append("Content-Type: image/jpeg\r\n\r\n")
body.append(imageData)
body.append("\r\n")

body.append("--\(boundary)--\r\n")
request.httpBody = body

URLSession.shared.dataTask(with: request) { data, response, error in
if let error = error {
DispatchQueue.main.async {
isLoading = false
errorMessage = "Error al subir la imagen: \(error.localizedDescription)"
showErrorAlert = true
}
return
}

guard let data = data else {
DispatchQueue.main.async {
isLoading = false
errorMessage = "No se recibió respuesta del servidor."
showErrorAlert = true
}
return
}

if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
let secureUrl = jsonResponse["secure_url"] as? String {
print("Imagen subida correctamente: \(secureUrl)")
saveProductToFirestore(imageUrl: secureUrl)
} else {
DispatchQueue.main.async {
isLoading = false
errorMessage = "Error al parsear la respuesta de Cloudinary."
showErrorAlert = true
}
}
}.resume()
}

// MARK: - Guardar producto en Firestore
func saveProductToFirestore(imageUrl: String) {
guard let userEmail = Auth.auth().currentUser?.email else {
isLoading = false
errorMessage = "No se pudo obtener el correo del usuario."
showErrorAlert = true
return
}

guard let priceDouble = Double(price) else {
isLoading = false
errorMessage = "Precio inválido."
showErrorAlert = true
return
}

FirestoreManager.shared.addProduct(name: title, description: description, price: priceDouble, userEmail: userEmail, imageUrl: imageUrl) { success in
DispatchQueue.main.async {
isLoading = false
if success {
showSuccessAlert = true
} else {
errorMessage = "Error al guardar el producto en Firestore."
showErrorAlert = true
}
}
}
}
}

// MARK: - Extensión útil para agregar Data
fileprivate extension Data {
mutating func append(_ string: String) {
if let data = string.data(using: .utf8) {
append(data)
}
}
}
