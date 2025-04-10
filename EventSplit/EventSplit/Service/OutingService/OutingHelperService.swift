import Foundation
import ContactsUI

class OutingHelperService {
    static let shared = OutingHelperService()
    
    private init() {}
    
    func convertContactsToParticipants(_ contacts: [CNContact]) -> [ParticipantDTO] {
        return contacts.map { contact in
            let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
            let email = contact.emailAddresses.first?.value as String? ?? ""
            
            return ParticipantDTO(
                id: UUID().uuidString,
                name: "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces),
                email: email.isEmpty ? nil : email,
                phoneNumber: phoneNumber
            )
        }
    }
    
    func convertParticipantsToJSON(_ contacts: [CNContact]) -> [String] {
        let participants = convertContactsToParticipants(contacts)
        
        return participants.map { participant in
            do {
                let jsonData = try JSONEncoder().encode(participant)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            } catch {
                print("Error converting participant to JSON: \(error)")
            }
            return "{}" 
        }
    }
}
