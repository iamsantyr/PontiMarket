import SwiftUI
import FirebaseAuth

struct AddProductView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var price = ""

    @State private var showCamera = false
    @State private var productImage: UIImage?

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
                        showCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Tomar foto")
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

                Button("Guardar") {
                    saveProductToFirestore()
                }
                .disabled(title.isEmpty || price.isEmpty || description.isEmpty)
            }
            .navigationTitle("Nuevo producto")
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $productImage)
            }
        }
    }

    func saveProductToFirestore() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: No se pudo obtener el correo del usuario.")
            return
        }

        guard let priceDouble = Double(price) else {
            print("Error: Precio inválido.")
            return
        }

        // Aquí podrías guardar la imagen en Firebase Storage, si lo deseas
        FirestoreManager.shared.addProduct(name: title, description: description, price: priceDouble, userEmail: userEmail) { success in
            if success {
                print("Producto guardado correctamente")
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Error al guardar el producto")
            }
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView()
    }
}
