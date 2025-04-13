//
//  ParticipantDebtList.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-03.
//
import SwiftUI

struct ParticipantDebtList: View {
    let users: [UserDTO]
    let participants: [ParticipantDTO]
    let debts: [DebtEntity]
    
    private var processedDebts: [Debt] {
        debts.map { debtEntity in
            Debt(
                from: debtEntity.fromUserId ?? "",
                to: debtEntity.toUserId ?? "",
                amount: debtEntity.amount
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if processedDebts.isEmpty {
                Text("All debts are settled")
                    .foregroundColor(.secondary)
            } else {
                ForEach(processedDebts, id: \.self) { debt in
                    DebtRow(debt: debt, users: users)
                }
            }
        }
    }

}

struct Debt: Hashable {
    let from: String
    let to: String
    let amount: Double
}

struct DebtRow: View {
    let debt: Debt
    let users: [UserDTO]
    
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
                        
                        Text("\(fromUser?.name ?? "Unknown") owes \(toUser?.name ?? "Unknown")")
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
                    .foregroundColor(.red)
                Spacer()
                Button(action: {}) {
                    Text("Mark as Paid")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .foregroundColor(.secondaryBackground)
                        .cornerRadius(100)
                }
                
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
            }
        }
        .padding()
        .background(.primaryBackground)
        .cornerRadius(12)
    }
}
