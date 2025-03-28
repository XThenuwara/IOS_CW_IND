import SwiftUI
import CoreData

class AuthCoreDataModel: ObservableObject {
    static let shared = AuthCoreDataModel()
    
    let container: NSPersistentContainer
    @Published var currentUser: AuthEntity?
    lazy var authService = AuthService(coreDataModel: self)
    
    private init() {
        container = NSPersistentContainer(name: "EventSplit")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("ERROR LOADING CORE DATA STORES: \(error)")
            } else {
                print("Successfully loaded the core data")
            }
        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        let request = NSFetchRequest<AuthEntity>(entityName: "AuthEntity")
        do {
            let results = try container.viewContext.fetch(request)
            currentUser = results.first
        } catch let error {
            print("Error fetching auth: \(error)")
        }
    }
    
    func saveAuthData(accessToken: String, user: [String: Any]) {
        clearAuthData()
    
        let auth = AuthEntity(context: container.viewContext)
        auth.accessToken = accessToken
        
        do {
            let userData = try JSONSerialization.data(withJSONObject: user)
            auth.user = String(data: userData, encoding: .utf8)
        } catch {
            print("Error converting user data: \(error)")
        }
        
        saveData()
        fetchCurrentUser()
    }
    
    func clearAuthData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AuthEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(batchDeleteRequest)
            currentUser = nil
        } catch let error {
            print("Error clearing auth data: \(error)")
        }
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving data: \(error)")
        }
    }


    // Server authentication methods
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        Task {
            await MainActor.run {
                authService.login(email: email, password: password) { [weak self] result in
                    switch result {
                    case .success(let authResponse):
                        self?.saveAuthData(
                            accessToken: authResponse.accessToken,
                            user: [
                                "id": authResponse.user.id.uuidString,
                                "name": authResponse.user.name,
                                "email": authResponse.user.email
                            ]
                        )
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func signup(name: String, email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        Task {
            await MainActor.run {
                authService.signup(name: name, email: email, password: password) { [weak self] result in
                    switch result {
                    case .success(let authResponse):
                        self?.saveAuthData(
                            accessToken: authResponse.accessToken,
                            user: [
                                "id": authResponse.user.id.uuidString,
                                "name": authResponse.user.name,
                                "email": authResponse.user.email
                            ]
                        )
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    
    func logout() {
        clearAuthData()
    }
    
    var isAuthenticated: Bool {
        return currentUser?.accessToken != nil
    }
}
