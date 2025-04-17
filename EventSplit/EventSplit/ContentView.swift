//
//  ContentView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-23.
//
import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 0
    @ObservedObject private var authModel = AuthCoreDataModel.shared
    @State private var showLogin = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        Group {
            if authModel.isAuthenticated {
                NavigationStack(path: $navigationPath) {
                    ZStack(alignment: .top) {
                        Color.primaryBackground
                            .ignoresSafeArea()
                        VStack(spacing: 0) {
                            Navbar(selectedTab: $selectedTab)
                                .padding(.bottom, 10)
                            
                            switch selectedTab {
                            case 0:
                                HomeView()
                            case 1:
                                BrowseView()
                            case 2:
                                OutingListView()
                            case 3:
                                GroupListView()
                            case 4:
                                TicketsListView()
                            default:
                                EmptyView()
                            }
                            
                            Tabbar(selectedTab: $selectedTab)
                        }
                    }
                    .navigationDestination(for: OutingEntity.self) { outing in
                        OutingView(outing: outing)
                    }
                }
            } else {
                Login()
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: Notification.Name("NotificationTapped"),
                object: nil,
                queue: .main
            ) { notification in
                guard let type = notification.userInfo?["type"] as? String,
                      let referenceId = notification.userInfo?["referenceId"] as? String else {
                    print("ContentView.onAppear: Missing notification data")
                    return
                }
                
                if let navigation = NotificationHandlerService.shared.handleNotificationTap(type: type, referenceId: referenceId) {
                    switch navigation {
                    case .outing(let id):
                        NotificationNavigationCoordinator.shared.navigateToOuting(id: id, navigationPath: $navigationPath)
                    case .activity, .settleUp, .group:
                        print("ContentView.onAppear: Navigation type not implemented")
                        break
                    }
                }
            }
        }
        .background(Color.primaryBackground)
    }
}

#Preview {
    ContentView()
}
