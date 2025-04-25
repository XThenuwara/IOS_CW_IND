//
//  DateRange.Filter.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-27.
//

import SwiftUI

struct DateRangeFilter: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var showingCalendar = false
    @State private var isDragging = false
    @State private var dragStartDate: Date?
    var onDateSelected: () -> Void
    
    var body: some View {
        VStack {
            Button(action: { showingCalendar.toggle() }) {
                HStack {
                    Text("Date")
                        .foregroundColor(.primary)
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .tint(.black)
                }
                .frame(width: 128, height: 20)
                .padding(.vertical, 12)
                .background(Color.highLightBackground)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.05), radius: 2)
            }
        }
        .sheet(isPresented: $showingCalendar) {
            NavigationView {
                MultiDatePicker("Select Range", selection: Binding(
                    get: {
                        var dates: Set<DateComponents> = []
                        let calendar = Calendar.current
                        
                        if let start = startDate {
                            dates.insert(calendar.dateComponents([.year, .month, .day], from: start))
                            
                            if let end = endDate {
                                
                                if end > start {
                                    var currentDate = calendar.date(byAdding: .day, value: 1, to: start)!
                                    while currentDate <= end {
                                        dates.insert(calendar.dateComponents([.year, .month, .day], from: currentDate))
                                        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                                    }
                                }
                            }
                        }
                        return dates
                    },
                    set: { newDates in
                        let calendar = Calendar.current
                        let sortedDates = newDates.compactMap { calendar.date(from: $0) }.sorted()
                        
                        
                        if sortedDates.count == 1 {
                            startDate = sortedDates[0]
                            endDate = nil
                        }
                  
                        else if sortedDates.count > 1 {
                            let first = sortedDates.first!
                            let last = sortedDates.last!
                            
                          
                            if let currentStart = startDate, first < currentStart {
                                startDate = first
                                endDate = nil
                            } else {
                                endDate = last
                            }
                        }

                        else {
                            startDate = nil
                            endDate = nil
                        }
                    }
                ))
                .navigationTitle("Select Date Range")
                .navigationBarItems(
                    leading: Button("Clear") {
                        startDate = nil
                        endDate = nil
                        onDateSelected()
                        showingCalendar = false
                    },
                    trailing: Button("Done") {
                        onDateSelected()
                        showingCalendar = false
                    }
                )
            }
        }
    }

}

#Preview {
    DateRangeFilter(
        startDate: .constant(nil),
        endDate: .constant(nil)
    ) {
        print("Date range selected")
    }
}

