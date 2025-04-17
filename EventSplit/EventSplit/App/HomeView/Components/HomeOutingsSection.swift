//
//  HomeOutingsSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import SwiftUI

struct HomeOutingsSection: View {
    @StateObject private var outingCoreData = OutingCoreDataModel()
    @State private var isLoading = false
    
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
            } else if !outingCoreData.outingStore.isEmpty {
                LazyVStack(spacing: 16) {
                    ForEach(Array(outingCoreData.outingStore.prefix(2))) { outing in
                        NavigationLink(destination: OutingView(outing: outing)) {
                            OutingCard(outing: outing)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                Text("No outings yet")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding(.horizontal)
        .task {
            isLoading = true
            await outingCoreData.refreshOutingsFromServer()
            isLoading = false
        }
    }
}