//
//  TicketsListView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import SwiftUI

struct TicketsListView: View {
    @State private var purchasedTickets: [PurchasedTicketsWithEventDTO] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    private let eventService = EventService(coreDataModel: EventCoreDataModel())
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Tickets")
                        .font(.system(size: 28, weight: .bold))
                    Text("View and manage your purchased tickets")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error loading tickets")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            loadTickets()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if purchasedTickets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "ticket")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Tickets Found")
                            .font(.headline)
                        Text("You haven't purchased any tickets yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(purchasedTickets, id: \.id) { ticket in
                        EventTicketsCard(ticket: ticket)
                            .listRowInsets(EdgeInsets())
                            .padding(.bottom, 6)
                            .padding(.top, 6)
                             .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.primaryBackground)
                    .padding(0)
                    .refreshable {
                        await loadTicketsAsync()
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color.primaryBackground)
        .onAppear {
            loadTickets()
        }
        
    }
    
    private func loadTickets() {
        isLoading = true
        error = nil
        
        eventService.getAllPurchasedTickets { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let tickets):
                    self.purchasedTickets = tickets
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
    
    private func loadTicketsAsync() async {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            eventService.getAllPurchasedTickets { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success(let tickets):
                        self.purchasedTickets = tickets
                    case .failure(let error):
                        self.error = error
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                isLoading = false
                self.error = error
            }
        }
    }
}

#Preview {
    TicketsListView()
}

