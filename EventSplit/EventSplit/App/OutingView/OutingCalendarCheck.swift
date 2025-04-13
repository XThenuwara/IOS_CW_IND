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
                            .foregroundColor(.blue)
                        
                        Text("Add to Calendar")
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    Text("Would you like to add this outing to your calendar?")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showAddToCalendarCard = false
                        }) {
                            Text("Skip")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            addToCalendar()
                        }) {
                            Text("Add")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4)
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