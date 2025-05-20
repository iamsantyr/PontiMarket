import SwiftUI
import Foundation

struct LanguageSelectorView: View {
    @Binding var selectedLanguage: String

    private let availableLanguages = ["English", "Spanish", "Portuguese", "French"]

    var body: some View {
        Menu {
            ForEach(availableLanguages, id: \.self) { lang in
                Button(action: {
                    selectedLanguage = lang
                }) {
                    Text(lang)
                }
            }
        } label: {
            VStack() {
                Image(systemName: "globe")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())

                Text("Select Language")
                    .foregroundColor(.black)
                    .font(.caption2)
                    .padding(.top,3)
            }
        }
        .padding(.top,10)
    }
}

/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}*/
