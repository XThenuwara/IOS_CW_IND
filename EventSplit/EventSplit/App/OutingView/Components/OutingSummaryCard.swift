//
//  OutingSummaryCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-29.
//
import SwiftUI

struct OutingSummaryCard: View {
    let totalBudget: Double
    let yourShare: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Expense")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", totalBudget))")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(yourShare < 0 ? "You Get" : "You Owe")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", abs(yourShare)))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(yourShare < 0 ? .green : .red)
                }
            }
            .padding()
        }
        .background(.primaryBackground)
        .cornerRadius(10)
    }
}
