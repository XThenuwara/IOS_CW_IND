import SwiftUI

struct CreateOutingDrawer: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var eventCoreData = EventCoreDataModel()
    @StateObject private var outingStore = OutingCoreDataModel()
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showEventPicker = false
    @State private var selectedEvents: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter outing title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Description Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            // Event Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Events")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showEventPicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Event")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Selected Events List
            if !selectedEvents.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedEvents), id: \.self) { eventId in
                            if let event = eventCoreData.eventStore.first(where: { $0.id == eventId }) {
                                EventChip(title: event.title ?? "Unknown", onRemove: {
                                    selectedEvents.remove(eventId)
                                })
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            // Create Button
            Button(action: {
                createOuting()
            }) {
                Text("Create Outing")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(title.isEmpty || description.isEmpty)
        }
        .padding()
        .sheet(isPresented: $showEventPicker) {
            EventPickerView(selectedEvents: $selectedEvents)
        }
        .onAppear {
            eventCoreData.fetchEvents()
        }
    }
    
    private func createOuting() {
        outingStore.createNewOuting(title: title, description: description)
    }
}

struct EventChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EventPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var eventCoreData = EventCoreDataModel()
    @Binding var selectedEvents: Set<UUID>
    
    var body: some View {
        NavigationView {
            List(eventCoreData.eventStore, id: \.id) { event in
                if let id = event.id {
                    HStack {
                        Text(event.title ?? "Unknown")
                        Spacer()
                        if selectedEvents.contains(id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedEvents.contains(id) {
                            selectedEvents.remove(id)
                        } else {
                            selectedEvents.insert(id)
                        }
                    }
                }
            }
            .navigationTitle("Select Events")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .onAppear {
            eventCoreData.fetchEvents()
        }
    }
}

#Preview {
    CreateOutingDrawer()
}
