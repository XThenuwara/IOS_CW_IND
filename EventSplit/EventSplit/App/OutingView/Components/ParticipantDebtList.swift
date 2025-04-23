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
                id: debtEntity.id?.uuidString ?? "",
                from: debtEntity.fromUserId ?? "",
                to: debtEntity.toUserId ?? "",
                amount: debtEntity.amount,
                status: debtEntity.status ?? ""
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

