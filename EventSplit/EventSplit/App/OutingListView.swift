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
                    Text("Your Outings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        outingCoreData.fetchOutings()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                    
                    Button(action: {
                        showNewOutingSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Outing")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.primaryBackground)
                        .foregroundColor(.secondaryBackground)
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
            }
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
