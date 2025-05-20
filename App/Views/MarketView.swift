import SwiftUI
import FirebaseFirestore

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

struct MarketView: View {
    @State private var products: [ProductData] = []
    @State private var showingAddProductSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                List(products) { product in
                    VStack(alignment: .leading) {
                        // Título corregido (era "title", ahora "name")
                        Text(product.data["name"] as? String ?? "Sin título")
                            .font(.headline)

                        // Descripción
                        Text(product.data["description"] as? String ?? "")
                            .font(.subheadline)

                        // Precio formateado
                        if let price = product.data["price"] as? Double {
                            Text(String(format: "$%.2f", price))
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else if let price = product.data["price"] as? NSNumber {
                            Text(String(format: "$%.2f", price.doubleValue))
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("Precio no disponible")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle("Marketplace")

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
                        .accessibilityLabel("Agregar producto")
                    }
                }
            }
        }
        .onAppear {
            fetchProducts()
        }
        .sheet(isPresented: $showingAddProductSheet) {
            AddProductView()
        }
    }

    func fetchProducts() {
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

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView()
    }
}
