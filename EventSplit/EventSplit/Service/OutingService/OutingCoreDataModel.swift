import SwiftUI
import CoreData

class OutingCoreDataModel: ObservableObject {
    let container: NSPersistentContainer
    @Published var outingStore: [OutingEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "EventSplit")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("ERROR LOADING CORE DATA STORES: \(error)")
            } else {
                print("Successfully loaded the core data")
            }
        }
    }
    
    func fetchOutings() {
        let request = NSFetchRequest<OutingEntity>(entityName: "OutingEntity")
        do {
            outingStore = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching outings: \(error)")
        }
    }
    
    func createNewOuting(title: String, description: String, event: EventEntity? = nil) {
        // Create and save to CoreData
        let newOuting = OutingEntity(context: container.viewContext)
        newOuting.id = UUID()
        newOuting.title = title
        newOuting.desc = description
        
        // Send to server
        let serverModel = OutingServerModel(coreDataModel: self)
        serverModel.createOuting(title: title, description: description) { _ in }
        saveData()
    }
    
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchOutings() // Refresh the store after saving
        } catch let error {
            print("Error saving data: \(error)")
        }
    }
}

struct OutingCoreDataModelPreview: View {
    @StateObject var viewModel = OutingCoreDataModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.outingStore, id: \.id) { outing in
                    OutingCard(outing: outing)
                }
            }
        }
        .onAppear {
            viewModel.fetchOutings()
        }
    }
}

#Preview {
    OutingCoreDataModelPreview()
}
