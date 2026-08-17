import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {

// MARK: - Coordinator
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
let parent: ImagePicker

init(_ parent: ImagePicker) {
self.parent = parent
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
if let uiImage = info[.originalImage] as? UIImage {
parent.image = uiImage
}
parent.presentationMode.wrappedValue.dismiss()
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
parent.presentationMode.wrappedValue.dismiss()
}
}

// MARK: - Properties
@Environment(\.presentationMode) var presentationMode
@Binding var image: UIImage?
var sourceType: UIImagePickerController.SourceType = .camera

func makeCoordinator() -> Coordinator {
Coordinator(self)
}

func makeUIViewController(context: Context) -> UIImagePickerController {
let picker = UIImagePickerController()
picker.delegate = context.coordinator

picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary

return picker
}

func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
