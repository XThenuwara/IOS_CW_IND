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
    @Environment(\.dismiss) private var dismiss
    
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var name = ""
    @State private var email = ""
    @State private var isProcessing = false
    @State private var quantity: Int = 1
    
    private let maxTickets = 10
    private let ticketPrice: Double = 29.99 // Replace with actual price from event
    
    var totalAmount: Double {
        ticketPrice * Double(quantity)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Purchase Tickets")
                        .font(.title3)
                        .fontWeight(.semibold)
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
                                        .foregroundColor(.blue)
                                }
                                
                                Text("\(quantity)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 30)
                                
                                Button(action: { if quantity < maxTickets { quantity += 1 } }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
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
                                Text("$\(String(format: "%.2f", ticketPrice))")
                            }
                            .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Total Amount")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("$\(String(format: "%.2f", totalAmount))")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Payment Details
                VStack(spacing: 16) {
                    Text("Payment Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 20) {
                        // Card Number
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Number")
                                .font(.subheadline)
                            TextField("4242 4242 4242 4242", text: $cardNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Expiry and CVV
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Expiry Date")
                                    .font(.subheadline)
                                TextField("MM/YY", text: $expiryDate)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CVV")
                                    .font(.subheadline)
                                TextField("123", text: $cvv)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }
                        
                        // Cardholder Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cardholder Name")
                                .font(.subheadline)
                            TextField("John Doe", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                            TextField("john@example.com", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
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
                            Text("Pay $\(String(format: "%.2f", totalAmount))")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func processPayment() {
        isProcessing = true
        
        let purchaseDTO = PurchaseTicketDTO(
            eventId: event.id?.uuidString ?? "",
            quantity: quantity,
            totalAmount: totalAmount,
            paymentDetails: .init(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cvv: cvv,
                cardholderName: name,
                email: email
            )
        )
        
        // TODO: Send purchaseDTO to your backend
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            dismiss()
        }
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let event = EventEntity(context: context)
        event.title = "Sample Event"
        event.id = UUID()
        
        return PaymentView(event: event)
    }
}
