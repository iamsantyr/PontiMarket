import SwiftUI
import FirebaseFirestore

// MARK: - Modelo de Producto
struct ProductData: Identifiable, Hashable {
var id: String
var data: [String: Any]

static func == (lhs: ProductData, rhs: ProductData) -> Bool {
return lhs.id == rhs.id
}

func hash(into hasher: inout Hasher) {
hasher.combine(id)
}
}

// MARK: - Vista del Marketplace
struct MarketView: View {

// MARK: - Estados
@State private var products: [ProductData] = []
@State private var showingAddProductSheet = false

// MARK: - Preferencia de idioma
@AppStorage("selectedLanguage") private var selectedLanguage: String = "es"

// MARK: - Vista
var body: some View {
NavigationView {
ZStack {
List {
ForEach(products) { product in
ProductCardView(product: product, language: selectedLanguage)
}
}
.listStyle(PlainListStyle())
.navigationTitle(getTranslation(for: "marketplaceTitle"))

// Botón de añadir producto
VStack {
Spacer()
HStack {
Spacer()
Button(action: {
showingAddProductSheet = true
}) {
Image(systemName: "plus")
.foregroundColor(.white)
.padding()
.background(Color.blue)
.clipShape(Circle())
.shadow(radius: 5)
}
.padding()
.accessibilityLabel(getTranslation(for: "addProduct"))
}
}
}
.background(Color(UIColor.systemBackground))
}
.onAppear(perform: fetchProducts)
.sheet(isPresented: $showingAddProductSheet) {
AddProductView()
}
}

// MARK: - Obtener traducción
private func getTranslation(for key: String) -> String {
return Languages.shared.getTranslation(for: key, language: selectedLanguage)
}

// MARK: - Obtener productos de Firestore
private func fetchProducts() {
let db = Firestore.firestore()
db.collection("products").addSnapshotListener { snapshot, error in
guard let documents = snapshot?.documents else {
print("No documents or error: \(error?.localizedDescription ?? "Unknown error")")
return
}

let newProducts = documents.map { doc in
ProductData(id: doc.documentID, data: doc.data())
}

DispatchQueue.main.async {
self.products = newProducts
}
}
}
}

// MARK: - Vista individual de producto
struct ProductCardView: View {
let product: ProductData
let language: String

var body: some View {
VStack(alignment: .leading, spacing: 6) {

// Imagen del producto si existe (Cloudinary)
if let imageUrl = product.data["imageUrl"] as? String,
let url = URL(string: imageUrl) {
AsyncImage(url: url) { phase in
switch phase {
case .empty:
ProgressView()
.frame(height: 180)
case .success(let image):
image
.resizable()
.scaledToFill()
.frame(height: 180)
.clipped()
.cornerRadius(8)
case .failure:
placeholderImage
@unknown default:
placeholderImage
}
}
}

// Nombre
Text(product.data["name"] as? String ?? "Sin título")
.font(.title2)
.fontWeight(.bold)
.foregroundColor(.primary)

// Descripción
Text(product.data["description"] as? String ?? "")
.font(.subheadline)
.foregroundColor(.secondary)

// Precio
if let price = product.data["price"] as? Double {
Text(String(format: "$%.2f", price))
.font(.headline)
.foregroundColor(.green)
} else if let price = product.data["price"] as? NSNumber {
Text(String(format: "$%.2f", price.doubleValue))
.font(.headline)
.foregroundColor(.green)
} else {
Text(Languages.shared.getTranslation(for: "priceNotAvailable", language: language))
.font(.caption)
.foregroundColor(.red)
}
}
.padding()
.frame(maxWidth: .infinity, alignment: .leading)
.background(Color(UIColor.secondarySystemBackground))
.cornerRadius(10)
.shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
.listRowInsets(EdgeInsets())
.padding(.horizontal)
.padding(.bottom, 8)
.listRowSeparator(.hidden)
}

// MARK: - Imagen de respaldo
private var placeholderImage: some View {
ZStack {
Color.gray.opacity(0.2)
Image(systemName: "photo")
.foregroundColor(.gray)
}
.frame(height: 180)
.cornerRadius(8)
}
}

// MARK: - Previews
struct MarketView_Previews: PreviewProvider {
static var previews: some View {
MarketView()
.preferredColorScheme(.dark)
MarketView()
.preferredColorScheme(.light)
}
}
