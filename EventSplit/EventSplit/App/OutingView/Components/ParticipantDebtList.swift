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
    let debts: [DebtDTO]
    
    private var processedDebts: [Debt] {
        debts.map { debtDTO in
            Debt(
                id: debtDTO.id.uuidString,
                from: debtDTO.fromUserId,
                to: debtDTO.toUserId,
                amount: Double(debtDTO.amount) ?? 0.0,
                status: debtDTO.status.rawValue
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

