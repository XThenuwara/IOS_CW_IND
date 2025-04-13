//
//  EventPickerDrawer.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-31.
//
import SwiftUI

struct EventPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var eventCoreData = EventCoreDataModel()
    @Binding var selectedEvents: Set<UUID>
    @State private var selectedEventId: UUID? = nil
    @State private var searchText = ""
    @State private var selectedLocation: String?
    @State private var showFilterSheet = false
    @State private var selectedType: EventTypeEnum? = nil
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    
    private func updateFilteredEvents() {
        let distance = Int(selectedLocation ?? "20") ?? 20
        eventCoreData.fetchFilteredEvents(
            distance: distance,
            type: selectedType,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    private func getFilterText() -> String {
        let typeText = selectedType?.displayName ?? "All"
        let locationText = "\(selectedLocation ?? "5")km"
        
        if let start = startDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            
            if let end = endDate {
                return "\(typeText) Events within \(locationText) from \(formatter.string(from: start)) to \(formatter.string(from: end))"
            }
            return "\(typeText) Events within \(locationText) from \(formatter.string(from: start))"
        }
        
        return "\(typeText) Events within \(locationText)"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                // Search and Filter Bar
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(width: 16, height: 16)
                            TextField("Search events...", text: $searchText)
                        }
                        .padding()
                        .frame(height: 40)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 2)
                        
                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .cornerRadius(23)
                                .shadow(color: Color.black.opacity(0.05), radius: 2)
                        }
                    }
                    
                    // Location and Type Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Slider(value: Binding(
                                    get: { Double(selectedLocation ?? "20") ?? 20.0 },
                                    set: {
                                        selectedLocation = String(Int($0))
                                        updateFilteredEvents()
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
                                updateFilteredEvents()
                            }
                            EventTypeFilter(selectedType: $selectedType) {
                                updateFilteredEvents()
                            }
                            
                            Button(action: {
                                selectedType = nil
                                selectedLocation = nil
                                startDate = nil
                                endDate = nil
                                eventCoreData.fetchEventsFromServer()
                            }) {
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
                .padding(.horizontal)
                
                // Events List
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(getFilterText())
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(eventCoreData.eventStore, id: \.id) { event in
                                if let id = event.id {
                                    SelectableEventCard(
                                        event: event,
                                        isSelected: selectedEventId == id,  
                                        onSelect: {
                                            if selectedEventId == id {
                                                selectedEventId = nil 
                                            } else {
                                                selectedEventId = id  
                                            }
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Select Events")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    selectedEvents = selectedEventId != nil ? [selectedEventId!] : [] 
                    dismiss()
                }
            )
        }
        .onAppear {
            selectedEventId = selectedEvents.first 
            eventCoreData.fetchEventsFromServer()
        }
        .background(.primaryBackground)
    }
}

#Preview {
    EventPickerView(selectedEvents: .constant(Set<UUID>()))
}
