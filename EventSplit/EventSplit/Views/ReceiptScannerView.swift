import SwiftUI
import PhotosUI

struct ReceiptScannerView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var extractedText: String = ""
    
    private let textExtractor = TextExtractionTest()
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Image(systemName: "doc.text.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("Select Receipt")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            ScrollView {
                Text(extractedText)
                    .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage, isPresented: $isImagePickerPresented)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                textExtractor.extractText(from: image) { result in
                    if let text = result {
                        extractedText = text
                    } else {
                        extractedText = "Failed to extract text"
                    }
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    ReceiptScannerView()
}