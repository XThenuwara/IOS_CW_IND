struct AuthErrorResponse: Codable {
    let message: String
    let error: String
    let statusCode: Int
}