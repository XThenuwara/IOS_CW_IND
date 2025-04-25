//
//  HomeOutingsSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import SwiftUI

struct HomeOutingsSection: View {
    @State private var outings: [OutingDTO] = []
    @State private var isLoading = false
    @State private var error: Error?
    private let outingService = OutingService(coreDataModel: OutingCoreDataModel())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Outings")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                NavigationLink(destination: OutingListView()) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                }
            }
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let error = error {
                Text("Failed to load outings")
                    .foregroundColor(.red)
                    .padding()
            } else if outings.isEmpty {
                Text("No outings yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(Array(outings.prefix(2)), id: \.id) { outing in
                        NavigationLink(destination: OutingView(outing: outing)) {
                            OutingCard(outing: outing)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal)
        .task {
            await refreshOutings()
        }
    }
    
    private func refreshOutings() async {
        isLoading = true
        error = nil
        
        outingService.fetchOutings { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedOutings):
                    self.outings = fetchedOutings
                case .failure(let fetchError):
                    self.error = fetchError
                }
            }
        }
    }
}
