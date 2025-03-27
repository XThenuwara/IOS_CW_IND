import SwiftUI

struct BrowseView: View {
    @StateObject private var eventModel = EventCoreDataModel()
    @State private var searchText = ""
    @State private var selectedLocation: String?
    @State private var showFilterSheet = false
    @State private var selectedType: EventTypeEnum? = nil
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    
    private func updateFilteredEvents() {
        let distance = Int(selectedLocation ?? "20") ?? 20
        eventModel.fetchFilteredEvents(
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
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Events Near You")
                        .font(.system(size: 28, weight: .bold))
                    Text("Discover events happening in your area")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
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
                            
                            Spacer().frame(width: 16) // Optional spacer for better scrolling
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
                            ForEach(eventModel.eventStore, id: \.id) { event in
                                EventCard(event: event)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(.primaryBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilterSheet) {
                NavigationView {
                    List {
                        // TODO:  Filter options here
                    }
                    .navigationTitle("Filter Events")
                    .navigationBarItems(trailing: Button("Done") {
                        showFilterSheet = false
                    })
                }
            }
        }
        .onAppear {
            eventModel.fetchFilteredEvents()
            eventModel.fetchEventsFromServer()
        }
        .onChange(of: eventModel.eventStore) { newValue in
            print("📋 Events updated - Count: \(newValue.count)")
        }
    }
}

#Preview {
    BrowseView()
        .background(.secondaryBackground)
}

