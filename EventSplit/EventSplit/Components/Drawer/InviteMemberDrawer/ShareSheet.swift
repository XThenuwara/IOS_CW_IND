import SwiftUI
import ContactsUI
import MessageUI

// Add after ContactPickerViewController
// Replace the existing ShareSheet implementation
// Fix the completion handler in ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            presentationMode.wrappedValue.dismiss()
        }
        
        // For iPad support
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.permittedArrowDirections = []
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}