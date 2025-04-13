//
//  OutingListView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-13.
//
import SwiftUI

struct OutingListView: View {
    @StateObject private var outingCoreData = OutingCoreDataModel()
    @State private var showNewOutingSheet = false
    @State private var selectedOuting: OutingEntity?
    @State private var showOutingDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                HStack {
                                VStack(alignment: .leading, spacing: 8) {
                Text("Your Outings")
                    .font(.system(size: 28, weight: .bold))
                Text("Manage and track your upcoming outings")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
                    
                    Spacer()
                    
                    // Button(action: {
                    //     outingCoreData.fetchOutings()
                    // }) {
                    //     Image(systemName: "arrow.clockwise")
                    //         .foregroundColor(.gray)
                    // }
                    // .padding(.trailing, 8)
                    
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
                
                // Outings List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(outingCoreData.outingStore, id: \.id) { outing in
                            NavigationLink(destination: OutingView(outing: outing)) {
                                OutingCard(outing: outing)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(.primaryBackground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showNewOutingSheet) {
                DrawerModal(isOpen: $showNewOutingSheet) {
                    CreateOutingDrawer()
                        .presentationDetents([.large])
                }
            }
            .onAppear {
                outingCoreData.refreshOutingsFromServer()
            }
        }
    }
}

#Preview {
    OutingListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
