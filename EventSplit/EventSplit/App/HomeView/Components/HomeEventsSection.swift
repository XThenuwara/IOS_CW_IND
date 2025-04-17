//
//  HomeEventsSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import SwiftUI

struct HomeEventsSection: View {
    @StateObject private var eventModel = EventCoreDataModel()
    @State private var isLoading = false
    
    private func fetchEvents() {
        eventModel.fetchEventsFromServer()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Events")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                     Button(action: {
                    fetchEvents()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.accentColor)
                }
                .padding(.trailing, 8)

                NavigationLink(destination: BrowseView()) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                }

                         if !eventModel.eventStore.isEmpty {
                LazyVStack(spacing: 16) {
                    ForEach(Array(eventModel.eventStore.prefix(2))) { event in
                        NavigationLink(destination: EventView(event: event)) {
                            EventCard(event: event)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                Text("No upcoming events")
                    .foregroundColor(.gray)
                    .padding()
            }
            }
            

        }
        .padding(.horizontal)
        .onAppear {
            fetchEvents()
        }
        .onChange(of: eventModel.eventStore) { _ in }
    }
}

#Preview {
    HomeEventsSection()
}