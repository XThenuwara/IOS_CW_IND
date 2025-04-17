//
//  PaymentView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct PurchaseTicketDTO: Codable {
    let eventId: String
    let quantity: Int
    let totalAmount: Double
    let paymentDetails: PaymentDetails
    
    struct PaymentDetails: Codable {
        let cardNumber: String
        let expiryDate: String
        let cvv: String
        let cardholderName: String
        let email: String
    }
}

struct PaymentView: View {
    let event: EventEntity
    let ticket: TicketDTO
    @StateObject private var eventModel = EventCoreDataModel()
    private let eventService: EventService
    @Environment(\.dismiss) private var dismiss

    init(event: EventEntity, ticket: TicketDTO) {
        self.event = event
        self.ticket = ticket
        self.eventService = EventService(coreDataModel: EventCoreDataModel())
    }
    
    
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var name = ""
    @State private var email = ""
    @State private var isProcessing = false
    @State private var quantity: Int = 1
    
    private let maxTickets = 10
    
    var totalAmount: Double {
        ticket.price * Double(quantity)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.secondaryBackground)
                    }
                    Spacer()
                    Text("Purchase Tickets")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondaryBackground)
                    Spacer()
                }
                .padding()
                
                // Cart Section
                VStack(spacing: 16) {
                    Text("Your Cart")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        Text(event.title ?? "Event")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Quantity Selector
                        HStack {
                            Text("Quantity")
                            Spacer()
                            HStack(spacing: 20) {
                                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.secondaryBackground)
                                }
                                
                                Text("\(quantity)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 30)
                                
                                Button(action: { if quantity < maxTickets { quantity += 1 } }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.secondaryBackground)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Price Summary
                        VStack(spacing: 8) {
                            HStack {
                                Text("Price per ticket")
                                Spacer()
                                Text("LKR \(String(format: "%.2f", ticket.price))")
                            }
                            .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Total Amount")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("LKR \(String(format: "%.2f", totalAmount))")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Payment Details
                VStack(spacing: 16) {
                    Text("Payment Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PaymentOptions(
                        cardNumber: $cardNumber,
                        expiryDate: $expiryDate,
                        cvv: $cvv,
                        name: $name,
                        email: $email
                    )
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Pay Button
                Button(action: processPayment) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Pay LKR\(String(format: "%.2f", totalAmount))")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.secondaryBackground)
                    .foregroundColor(.primaryBackground)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
                .padding()
            }
        }
        .background(.primaryBackground)
        .navigationBarHidden(true)
    }
    
    private func processPayment() {
        isProcessing = true
        
        let purchaseTicket = PurchaseTicketItem(
            ticketType: ticket.name,
            quantity: quantity
        )
        
        eventService.purchaseTickets(
            eventId: event.id ?? UUID(),
            tickets: [purchaseTicket],
            paymentMethod: "CARD",
            completion: { result in
                DispatchQueue.main.async {
                    isProcessing = false
                    
                    switch result {
                    case .success(_):
                        // Show success message or handle success case
                        dismiss()
                    case .failure(let error):
                        // Handle error case
                        print("Payment failed: \(error.localizedDescription)")
                    }
                }
            }
        )
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let event = EventEntity(context: context)
        event.title = "Sample Event"
        event.id = UUID()
        
        let ticket = TicketDTO(id: "1", name: "General", price: 29.99, totalQuantity: 100, soldQuantity: 50)
        
        return PaymentView(event: event, ticket: ticket)
    }
}
