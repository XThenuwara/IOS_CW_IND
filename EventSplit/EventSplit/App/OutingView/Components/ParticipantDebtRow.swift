//
//  DebtRow.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct Debt: Hashable {
    let id: String
    let from: String
    let to: String
    let amount: Double
    var status: String
}

struct DebtRow: View {
    @State private var debtStatus: String 
    let debt: Debt
    let users: [UserDTO]
    @State private var isUpdating = false
    let outingService = OutingService(coreDataModel: OutingCoreDataModel.shared)
    var onStatusUpdate: ((String) -> Void)?
    
    init(debt: Debt, users: [UserDTO], onStatusUpdate: ((String) -> Void)? = nil) {
        self.debt = debt
        self.users = users
        self.onStatusUpdate = onStatusUpdate
        _debtStatus = State(initialValue: debt.status) 
    }
    
    private var fromUser: UserDTO? {
        users.first { $0.id.uuidString.lowercased() == debt.from.lowercased() }
    }
    
    private var toUser: UserDTO? {
        users.first { $0.id.uuidString.lowercased() == debt.to.lowercased() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar and Info
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(fromUser?.name.prefix(2) ?? "NA")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(fromUser?.name ?? "Unknown") → \(toUser?.name ?? "Unknown")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(debtStatus == "paid" ? "Debt settled" : "\(fromUser?.name ?? "Unknown") owes \(toUser?.name ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Buttons Row
            HStack(spacing: 8) {
                Text("$\(String(format: "%.2f", debt.amount))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                
                if debtStatus != "paid" {
                    Button(action: updateDebtStatus) {
                        if isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .secondaryBackground))
                                .frame(width: 16, height: 16)
                        } else {
                            Text("Mark as Paid")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    .disabled(isUpdating)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .foregroundColor(.secondaryBackground)
                    .cornerRadius(100)
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign")
                            Text("Pay Now")
                                .fontWeight(.bold)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.secondaryBackground)
                        .foregroundColor(.primaryBackground)
                        .cornerRadius(16)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.large)
                        Text("Paid")
                           .fontWeight(.bold)
                    }
                   .font(.caption)
                   .padding(.horizontal, 12)
                   .padding(.vertical, 6)
                   .background(.highLightBackground)
                   .cornerRadius(100)
                }
            }
        }
        .padding()
        .background(.primaryBackground)
        .cornerRadius(12)
        .opacity(debtStatus == "paid" ? 0.8 : 1)
    }

        private func updateDebtStatus() {
        isUpdating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            outingService.updateDebtStatus(debtId: debt.id, status: "paid") { result in
                DispatchQueue.main.async {
                    isUpdating = false
                    switch result {
                    case .success(_):
                        debtStatus = "paid"
                        onStatusUpdate?("paid")
                        print("Successfully marked debt as paid")
                    case .failure(let error):
                        print("Failed to mark debt as paid: \(error)")
                    }
                }
            }
        }
    }
}
