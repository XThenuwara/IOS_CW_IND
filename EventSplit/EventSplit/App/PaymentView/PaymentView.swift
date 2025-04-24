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
    var ticket: TicketDTO
    let outingId: UUID?
    let onPaymentSuccess: () -> Void
    
    @State private var showError = false
    @State private var infoMessage = ""
    @State private var showSuccess = false
    @State private var buttonState: ActionButtonState = .default
    @StateObject private var eventModel = EventCoreDataModel()
    private let eventService: EventService
    @Environment(\.dismiss) private var dismiss
    
    init(event: EventEntity, ticket: TicketDTO, outingId: UUID? = nil, onPaymentSuccess: @escaping () -> Void = {} ) {
        self.event = event
        self.ticket = ticket
        self.outingId = outingId
        self.onPaymentSuccess = onPaymentSuccess
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
                    VStack(spacing: 4) {
                        Text("Purchase Tickets")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondaryBackground)
                        Text("Complete your secure transaction with our trusted payment gateway")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.secondaryBackground)
                    }
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
                
                if showError {
                    InfoTile(
                        message: infoMessage,
                        isVisible: $showError
                    )
                }
                
                // Pay Button
                ActionButton(
                    title: "Pay LKR\(String(format: "%.2f", totalAmount))",
                    action: processPayment,
                    state: buttonState
                )
                .padding(.horizontal)
                
                Text("By proceeding with the payment, you agree to our terms and conditions. All payments are secure and encrypted.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                
            }
        }
        .background(.primaryBackground)
        .navigationBarHidden(true)
    }
    
    private func processPayment() {
        buttonState = .loading
        
        let purchaseTicket = PurchaseTicketItem(
            ticketType: ticket.name,
            quantity: quantity
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            eventService.purchaseTickets(
                eventId: event.id ?? UUID(),
                tickets: [purchaseTicket],
                paymentMethod: "CARD",
                outingId: outingId,
                completion: { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            buttonState = .success
                            showSuccess = true
                            infoMessage = "Payment successful!"
                            onPaymentSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        case .failure(let error):
                            buttonState = .error
                            infoMessage = error.localizedDescription
                            showError = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                buttonState = .default
                            }
                        }
                    }
                }
            )
        }
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
