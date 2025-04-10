import SwiftUI
import CoreData

class OutingCoreDataModel: ObservableObject {
    static let shared = OutingCoreDataModel()
    let container: NSPersistentContainer
    lazy var serverModel = OutingService(coreDataModel: self)
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
        serverModel.fetchOutings();
        let request = NSFetchRequest<OutingEntity>(entityName: "OutingEntity")
        do {
            outingStore = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching outings: \(error)")
        }
    }

    func refreshOutingsFromServer() {
        outingStore.removeAll()
        serverModel.fetchOutings()
    }
    
    func createNewOuting(
        title: String,
        description: String,
        event: EventEntity? = nil,
        participants: [String]? = nil
    ) {
        // Server Call
        serverModel.createOuting(
            title: title,
            description: description,
            eventId: event?.id?.uuidString.lowercased(),
            participants: participants
        ) { result in
            switch result {
            case .success(let outingDTO):
                DispatchQueue.main.async {
                    if let outingEntity = self.serverModel.convertToOutingEntity(outingDTO: outingDTO, context: self.container.viewContext) {
                        self.outingStore.append(outingEntity)
                        self.saveData()
                    }
                }
            case .failure(let error):
                print("Error creating outing: \(error)")
            }
        }
    }
    
    func addActivity(
        title: String,
        description: String,
        amount: Double,
        participantIds: [String],
        outingId: String,
        paidById: String,
        references: [String]? = nil
    ) {        
        serverModel.addActivity(
            title: title,
            description: description,
            amount: amount,
            participantIds: participantIds,
            paidById: paidById,
            outingId: outingId,
            references: references
        ) { [weak self] result in
            switch result {
            case .success(let response):
                print("✅ Activity added successfully")
                DispatchQueue.main.async {
                
                    self?.fetchOutings()
                }
            case .failure(let error):
                print("❌ Error adding activity: \(error)")
            }
        }
    }
    
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchOutings()
        } catch let error {
            print("Error saving data: \(error)")
        }
    }
    
    func clearAllOutings() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = OutingEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
            outingStore.removeAll()
        } catch let error {
            print("Error clearing outings: \(error)")
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
