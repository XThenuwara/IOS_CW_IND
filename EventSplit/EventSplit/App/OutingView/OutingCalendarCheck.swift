//
//  OutingCalendarCheck.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct OutingCalendarCheck: View {
    let title: String
    let description: String
    let startDate: Date?
    @State private var showAddToCalendarCard = false
    
    var body: some View {
        VStack {
            if showAddToCalendarCard {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(.secondaryBackground)
                        
                        Text("Add to Calendar")
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    Text("Would you like to add this outing to your calendar?")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        Spacer()
                        Button(action: {
                            showAddToCalendarCard = false
                        }) {
                            Text("Skip")
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.primaryBackground)
                                .foregroundColor(.secondaryBackground)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            addToCalendar()
                        }) {
                            Text("Add")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                                        .background(.secondaryBackground)
                        .foregroundColor(.primaryBackground)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .withShadow()
                .withBorder()
                .padding(.horizontal)
            }
        }
        .onAppear {
            checkCalendarEvent()
        }
    }
    
    private func checkCalendarEvent() {
        if !CalendarService.shared.checkIfEventExists(title: title, startDate: startDate) {
            showAddToCalendarCard = true
        }
    }
    
    private func addToCalendar() {
        CalendarService.shared.addEventToCalendar(
            title: title,
            description: description,
            startDate: startDate
        ) { success in
            if success {
                showAddToCalendarCard = false
            }
        }
    }
}