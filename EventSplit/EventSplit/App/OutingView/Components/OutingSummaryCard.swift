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
                    Text("Your Share")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", yourShare))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
