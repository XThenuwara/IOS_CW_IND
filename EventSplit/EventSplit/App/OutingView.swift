import SwiftUI

struct OutingView: View {
    @StateObject private var outingCoreData = OutingCoreDataModel()
    @State private var showNewOutingSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Your Outings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
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
                        OutingCard(outing: outing)
                            .padding(.horizontal)
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
            outingCoreData.fetchOutings()
        }
    }
}

#Preview {
    OutingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
