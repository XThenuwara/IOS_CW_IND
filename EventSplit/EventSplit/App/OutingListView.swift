//
//  OutingListView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-13.
//
import SwiftUI

struct OutingListView: View {
    @State private var outings: [OutingDTO] = []
    @State private var showNewOutingSheet = false
    @State private var isLoading = false
    @State private var error: Error?
    private let outingService = OutingService(coreDataModel: OutingCoreDataModel())
    
    var body: some View {
        NavigationView {
            outingContent
        }
    }
    
    private var outingContent: some View {
        VStack(spacing: 16) {
            outingHeader
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error loading outings")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        refreshOutings()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else if outings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No Outings Found")
                        .font(.headline)
                    Text("Create your first outing to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                outingList
            }
        }
        .background(.primaryBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showNewOutingSheet) {
            DrawerModal(isOpen: $showNewOutingSheet) {
                CreateOutingDrawer(onSuccess: {
                    withAnimation {
                        refreshOutings()
                    }
                })
                .presentationDetents([.large])
            }
        }
        .onAppear {
            withAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        refreshOutings()
                    }
                }
            }
        }
    }
    
    private var outingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Outings")
                    .font(.system(size: 28, weight: .bold))
                Text("Manage and track your upcoming outings")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                showNewOutingSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("New")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.secondaryBackground)
                .foregroundColor(.primaryBackground)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
    }
    
    private var outingList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(outings, id: \.id) { outing in
                    NavigationLink {
                        OutingView(outing: outing)
                    } label: {
                        OutingCard(outing: outing)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func refreshOutings() {
        isLoading = true
        error = nil
        
        outingService.fetchOutings { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedOutings):
                    self.outings = fetchedOutings
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
    
}

#Preview {
    OutingListView()
}
