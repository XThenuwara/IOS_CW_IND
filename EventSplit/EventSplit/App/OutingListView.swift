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
    @State private var refresh = false
    
    var body: some View {
        NavigationView {
            outingContent
        }
    }
    
    private var outingContent: some View {
        VStack(spacing: 16) {
            outingHeader
            outingList
        }
        .background(.primaryBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showNewOutingSheet) {
            DrawerModal(isOpen: $showNewOutingSheet) {
                CreateOutingDrawer(onSuccess: {
                    refresh = true
                })
                .presentationDetents([.large])
            }
        }
        .onAppear {
            outingCoreData.refreshOutingsFromServer()
        }
        .onChange(of: refresh) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    outingCoreData.refreshOutingsFromServer()
                    refresh = false
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
                ForEach(outingCoreData.outingStore, id: \.id) { outing in
                    let viewContext = PersistenceController.shared.container.viewContext
                    NavigationLink {
                        OutingView(initialOuting: outing)
                            .environment(\.managedObjectContext, viewContext)
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
}

#Preview {
    OutingListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
