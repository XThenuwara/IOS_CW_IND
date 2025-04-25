//
//  OutingCalendarCheck.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI
import UIKit

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
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.primaryBackground)
                                .foregroundColor(.secondaryBackground)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            addToCalendar()
                        }) {
                            Text("Add")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.secondaryBackground)
                                .foregroundColor(.primaryBackground)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(.highLightBackground)
                .cornerRadius(12)
                .withShadow()
                .withBorder()
                .padding(.horizontal)
            } else {
                Button(action: {
                    if let startDate = startDate {
                        CalendarService.shared.openEventInCalendar(title: title, startDate: startDate)
                    }
                }) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundColor(.secondaryBackground)
                            Text("Event Added to Calendar")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(.highLightBackground)
                    .cornerRadius(12)
                    .withShadow()
                    .withBorder()
                    .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .animation(.spring(response: 1, dampingFraction: 0.8), value: showAddToCalendarCard)
        .onAppear {
            checkCalendarEvent()
        }
    }
    
    private func checkCalendarEvent() {
        print("Checking calendar event...")
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
