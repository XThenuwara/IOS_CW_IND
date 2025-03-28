import Foundation

struct LoginDTO: Codable {
    let email: String
    let password: String
}

struct SignUpDTO: Codable {
    let name: String
    let email: String
    let password: String
}

class AuthService {
    private let serverURL = URL(string: "http://localhost:3000/auth")!
    weak var coreDataModel: AuthCoreDataModel?
    
    init(coreDataModel: AuthCoreDataModel) {
        self.coreDataModel = coreDataModel
    }
    
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, AuthError>) -> Void) {
        let loginDTO = LoginDTO(email: email, password: password)
        let loginURL = serverURL.appendingPathComponent("login")
        
        let requestResult = NetworkHelper.createRequest(url: loginURL, method: "POST", body: loginDTO)
        
        switch requestResult {
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                NetworkHelper.handleResponse(data, response, error, completion: completion)
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func signup(name: String, email: String, password: String, completion: @escaping (Result<AuthResponse, AuthError>) -> Void) {
        let signupDTO = SignUpDTO(name: name, email: email, password: password)
        let signupURL = serverURL.appendingPathComponent("signup")
        
        let requestResult = NetworkHelper.createRequest(url: signupURL, method: "GET", body: signupDTO)        
        
        switch requestResult {
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                NetworkHelper.handleResponse(data, response, error, completion: completion)
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

