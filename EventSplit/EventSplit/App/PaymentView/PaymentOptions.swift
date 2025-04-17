import SwiftUI

enum PaymentMethod: String, CaseIterable {
    case card = "Card"
    case paypal = "PayPal"
    case applePay = "Apple Pay"
    case stripe = "Stripe"
    
    var icon: String {
        switch self {
        case .card: return "creditcard"
        case .paypal: return "p.circle"
        case .applePay: return "apple.logo"
        case .stripe: return "s.circle"
        }
    }
}

struct PaymentOptions: View {
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @Binding var name: String
    @Binding var email: String
    @State private var selectedMethod: PaymentMethod = .card
    
    var body: some View {
        VStack(spacing: 20) {
            // Payment Method Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Button(action: { selectedMethod = method }) {
                            HStack(spacing: 6) {
                                Image(systemName: method.icon)
                                    .font(.system(size: 16))
                                Text(method.rawValue)
                                    .font(.footnote)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedMethod == method ? .secondaryBackground : .clear)
                            .foregroundColor(selectedMethod == method ? .primaryBackground : .secondary)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .background(.primaryBackground)
            .cornerRadius(12)
            
            // Payment Form
            switch selectedMethod {
            case .card:
                CardPaymentForm(
                    cardNumber: $cardNumber,
                    expiryDate: $expiryDate,
                    cvv: $cvv,
                    name: $name,
                    email: $email
                )
            case .paypal:
                PayPalForm(email: $email)
            case .applePay:
                ApplePayForm()
            case .stripe:
                StripePaymentForm(
                    cardNumber: $cardNumber,
                    expiryDate: $expiryDate,
                    cvv: $cvv,
                    name: $name,
                    email: $email
                )
            }
        }
    }
}

// Add new Stripe form
struct StripePaymentForm: View {
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @Binding var name: String
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 20) {
            InputField(
                text: $cardNumber,
                placeholder: "4242 4242 4242 4242",
                icon: "creditcard",
                label: "Card Number"
            )
            
            HStack(spacing: 16) {
                InputField(
                    text: $expiryDate,
                    placeholder: "MM/YY",
                    icon: "calendar",
                    label: "Expiry Date"
                )
                
                InputField(
                    text: $cvv,
                    placeholder: "123",
                    icon: "lock",
                    label: "CVV"
                )
            }
            
            InputField(
                text: $email,
                placeholder: "john@example.com",
                icon: "envelope",
                label: "Email"
            )
            
            Text("Powered by Stripe")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct CardPaymentForm: View {
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @Binding var name: String
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 20) {
            InputField(
                text: $cardNumber,
                placeholder: "4242 4242 4242 4242",
                icon: "creditcard",
                label: "Card Number"
            )
            
            HStack(spacing: 16) {
                InputField(
                    text: $expiryDate,
                    placeholder: "MM/YY",
                    icon: "calendar",
                    label: "Expiry Date"
                )
                
                InputField(
                    text: $cvv,
                    placeholder: "123",
                    icon: "lock",
                    label: "CVV"
                )
            }
            
            InputField(
                text: $name,
                placeholder: "John Doe",
                icon: "person",
                label: "Cardholder Name"
            )
            
            InputField(
                text: $email,
                placeholder: "john@example.com",
                icon: "envelope",
                label: "Email"
            )
        }
    }
}

struct PayPalForm: View {
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 20) {
            InputField(
                text: $email,
                placeholder: "paypal@email.com",
                icon: "envelope",
                label: "PayPal Email"
            )
            
            Text("You will be redirected to PayPal to complete your payment")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

struct ApplePayForm: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "apple.logo")
                .font(.system(size: 48))
            
            Text("You will be prompted to confirm payment with Face ID or Touch ID")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}