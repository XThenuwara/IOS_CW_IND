import SwiftUI

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}


struct ExpenseViewDrawer: View {
    let users: [UserDTO]
    let activity: ActivityDTO
    @Environment(\.dismiss) private var dismiss
    @StateObject private var outingCoreDataModel = OutingCoreDataModel()
    @State private var activityImages: [URL] = []
    @State private var isLoadingImages = false
    @State private var selectedImage: IdentifiableImage?
    @State private var showImageViewer = false
    
    private let outingService: OutingService
    
    init(users: [UserDTO], activity: ActivityDTO) {
        self.users = users
        self.activity = activity
        let outingCoreDataModel =  OutingCoreDataModel.shared
        self.outingService = OutingService(coreDataModel: OutingCoreDataModel.shared)
    }
    
    private var paidByUser: UserDTO? {
        users.first { $0.id.uuidString.lowercased() == activity.paidById?.lowercased() }
    }
    
    private var amountPerPerson: Double {
        activity.amount / Double(activity.participants.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ExpenseHeaderSection(activity: activity, paidByUser: paidByUser)
                
                // Add Images Section
                if !activityImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(activityImages, id: \.self) { imageUrl in
                                AsyncImage(url: imageUrl) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 200, height: 150)
                                            .clipped()
                                            .cornerRadius(12)
                                            .onTapGesture {
                                                Task {
                                                    if let data = try? Data(contentsOf: imageUrl),
                                                       let uiImage = UIImage(data: data) {
                                                        await MainActor.run {
                                                            selectedImage = IdentifiableImage(image: uiImage)
                                                            showImageViewer = true
                                                        }
                                                    }
                                                }
                                            }
                                    case .failure(_):
                                        Image(systemName: "photo")
                                            .frame(width: 200, height: 150)
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 200, height: 150)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 200, height: 150)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                ExpenseDetailsSection(users: users, activity: activity, amountPerPerson: amountPerPerson)
            }
        }
        .fullScreenCover(item: $selectedImage) { identifiableImage in
            ImageViewer(image: identifiableImage.image)
        }
        .background(Color(.primaryBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
            }
        }
        .task {
            await loadActivityImages()
        }
    }
    
    private func loadActivityImages() async {
        isLoadingImages = true
        outingService.getActivityImages(activityId: activity.id.uuidString) { result in
            DispatchQueue.main.async {
                isLoadingImages = false
                switch result {
                case .success(let urls):
                    activityImages = urls
                case .failure(let error):
                    print("Failed to load activity images: \(error)")
                }
            }
        }
    }
}

private struct ExpenseHeaderSection: View {
    let activity: ActivityDTO
    let paidByUser: UserDTO?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", activity.amount))")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.secondaryBackground)
            }
            .padding(.horizontal)
            
            // Paid By Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Paid By")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(.secondaryBackground))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(paidByUser?.name.prefix(1) ?? "U"))
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(paidByUser?.name ?? "Unknown")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Paid on \(formatDate(activity.createdAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal)
        }
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString,
              let date = ISO8601DateFormatter().date(from: dateString) else {
            return "Unknown date"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct ExpenseDetailsSection: View {
    let users: [UserDTO]
    let activity: ActivityDTO
    let amountPerPerson: Double
    
    var body: some View {
        VStack(spacing: 24) {
            // Participants Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Split Between")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    ForEach(activity.participants, id: \.self) { participantId in
                        if let user = users.first(where: { $0.id.uuidString.lowercased() == participantId.lowercased() }) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(.secondaryBackground))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(String(user.name.prefix(1)))
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    )
                                
                                Text(user.name)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", amountPerPerson))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}

extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        
        if let view = controller.view {
            let contentSize = view.intrinsicContentSize
            view.bounds = CGRect(origin: .zero, size: contentSize)
            view.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: contentSize)
            return renderer.image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
        }
        return nil
    }
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.resizable().aspectRatio(contentMode: .fit))
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
