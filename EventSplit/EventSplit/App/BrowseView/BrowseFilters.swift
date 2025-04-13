//
//  BrowseFilters.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct BrowseFilters: View {
    @Binding var selectedLocation: String
    @Binding var selectedType: EventTypeEnum?
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    let onFilterUpdate: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Slider(value: Binding(
                        get: { Double(selectedLocation) ?? 20.0 },
                        set: {
                            selectedLocation = String(Int($0))
                            onFilterUpdate()
                        }
                    ), in: 1...20000, step: 1)
                    .tint(.gray)
                }
                .frame(width: 198, height: 20)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.05), radius: 2)
                
                DateRangeFilter(
                    startDate: $startDate,
                    endDate: $endDate
                ) {
                    onFilterUpdate()
                }
                
                EventTypeFilter(selectedType: $selectedType) {
                    onFilterUpdate()
                }
                
                Button(action: onReset) {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(23)
                        .shadow(color: Color.black.opacity(0.05), radius: 2)
                }
                
                Spacer().frame(width: 16)
            }
            .padding(.horizontal, 4)
        }
    }
}
