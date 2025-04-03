import SwiftUI
import ContactsUI
import MessageUI
// Add to Info.plist:
// NSContactsUsageDescription: "EventSplit needs access to contacts to help you invite friends"

// Add after the ContactRow struct
struct ContactPickerViewController: UIViewControllerRepresentable {
    @Binding var selectedContact: CNContact?
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Update the ContactPickerViewController Coordinator
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerViewController
        
        init(_ parent: ContactPickerViewController) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            DispatchQueue.main.async {
                self.parent.selectedContact = contact
                picker.dismiss(animated: true)
            }
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            picker.dismiss(animated: true)
        }
    }
}