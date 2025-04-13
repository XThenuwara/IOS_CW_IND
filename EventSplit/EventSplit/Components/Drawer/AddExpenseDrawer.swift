//
//  LLMService.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-08.
//
import SwiftUI
import PhotosUI
import UIKit

struct AddExpenseDrawer: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var outingCoreDataModel = OutingCoreDataModel()
    @State private var currentUserId: String = ""
    @State private var expenseName: String = ""
    @State private var expenseCategory: String = ""
    @State private var merchantName: String = ""
    @State private var amount: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isCameraPresented = false
    @State private var selectedParticipants: Set<String> = []
    @State private var searchText: String = ""
    @State private var paidById: String = ""
    @State private var errors: [String] = []
    @State private var isErrorVisible = false

    let outing: OutingEntity
    
    init(outing: OutingEntity) {
        print("[AddExpenseDrawer] Outing ID:", outing.id?.uuidString ?? "nil")
        self.outing = outing
        if let currentUser = AuthCoreDataModel.shared.currentUser {
            _currentUserId = State(initialValue: currentUser.id.uuidString)
        }
    }
    
    private var participants: [ParticipantDTO] {
        var allParticipants: [ParticipantDTO] = []
        
        // Add current user first
        if let currentUser = AuthCoreDataModel.shared.currentUser {
            let currentUserParticipant = ParticipantDTO(
                id: currentUser.id.uuidString,
                name: currentUser.name,
                email: currentUser.email,
                phoneNumber: currentUser.phoneNumber
            )
            allParticipants.append(currentUserParticipant)
        }
        
        // Add other participants
        if let participantsString = outing.participants,
           let data = participantsString.data(using: .utf8) {
            do {
                let participantStrings = try JSONDecoder().decode([String].self, from: data)
                
                let otherParticipants = try participantStrings.compactMap { participantString -> ParticipantDTO? in
                    guard let data = participantString.data(using: .utf8) else { return nil }
                    return try JSONDecoder().decode(ParticipantDTO.self, from: data)
                }
                
                allParticipants.append(contentsOf: otherParticipants)
            } catch {
                print("Decoding Error:", error)
            }
        }
        
        return allParticipants
    }
    

    
    private var filteredParticipants: [ParticipantDTO] {
        if searchText.isEmpty {
            return participants
        }
        return participants.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    


    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add New Expense")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Receipt Scanner
                        AddExpenseReceiptScanner(
                            selectedImage: $selectedImage,
                            isImagePickerPresented: $isImagePickerPresented,
                            isCameraPresented: $isCameraPresented,
                            onAnalysis: { analysis in
                                if let totalAmount = analysis.totalAmount {
                                    self.amount = String(format: "%.2f", totalAmount)
                                }
                                if let category = analysis.category {
                                    self.expenseCategory = category
                                }
                                if let merchant = analysis.merchantName {
                                    self.merchantName = merchant
                                }

                                var expenseTitle = ""
                                if !merchantName.isEmpty {
                                    expenseTitle = merchantName
                                    if !expenseCategory.isEmpty {
                                        expenseTitle = "\(expenseCategory) - \(merchantName)"
                                    }
                                } else if !expenseCategory.isEmpty {
                                    expenseTitle = expenseCategory
                                }
                                
                                if !expenseTitle.isEmpty {
                                    self.expenseName = expenseTitle
                                }
                            }
                        )
                        
                        // Expense Details
                        VStack(alignment: .leading, spacing: 16) {
                            InputField(
                                text: $expenseName,
                                placeholder: "e.g., Dinner, Tickets, etc.",
                                icon: nil,
                                label: "Expense Name"
                            )
                            
                            if !expenseCategory.isEmpty {
                                HStack {
                                    Text(expenseCategory)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                }
                            }
                            
                            InputField(
                                text: $amount,
                                placeholder: "$ 0.00",
                                icon: nil,
                                label: "Amount"
                            )
                            .keyboardType(.decimalPad)
                        }
                        
                        // Paid By
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Paid By")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.flexible())], spacing: 8) {
                                    ForEach(filteredParticipants, id: \.id) { participant in
                                        ParticipantChip(
                                            name: participant.id == currentUserId 
                                                ? "\(participant.name) (me)"
                                                : participant.name,
                                            isSelected: paidById == participant.id,
                                            action: {
                                                paidById = participant.id
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .frame(height: 50)
                        }
                        
                        // Split Between
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Split Between")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.flexible())], spacing: 8) {
                                    ForEach(filteredParticipants, id: \.id) { participant in
                                        ParticipantChip(
                                            name: participant.id == currentUserId 
                                                ? "\(participant.name) (me)"
                                                : participant.name,
                                            isSelected: selectedParticipants.contains(participant.id),
                                            action: {
                                                if selectedParticipants.contains(participant.id) {
                                                    selectedParticipants.remove(participant.id)
                                                } else {
                                                    selectedParticipants.insert(participant.id)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .frame(height: 50)
                            
                            InputField(
                                text: $searchText,
                                placeholder: "Search participants...",
                                icon: "magnifyingglass",
                                label: ""
                            )
                        }
                        
                        // Add Expense Button
                        Button(action: addExpense) {
                            Text("Add Expense")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            
            // Add ErrorCard overlay
            if !errors.isEmpty {
                ErrorCard(
                    message: errors.first ?? "",
                    isVisible: isErrorVisible,
                    onDismiss: {
                        isErrorVisible = false
                        errors.removeAll()
                    }
                )
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            NavigationView {
                ImagePicker(image: $selectedImage, isPresented: $isImagePickerPresented)
                    .navigationBarItems(trailing: Button("Cancel") {
                        isImagePickerPresented = false
                    })
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            NavigationView {
                ImagePicker(image: $selectedImage, isPresented: $isCameraPresented)
                    .navigationBarItems(trailing: Button("Cancel") {
                        isCameraPresented = false
                    })
                    .ignoresSafeArea()
            }
        }
    }
    
    

    
    private func addExpense() {
        errors.removeAll()
        
        guard let amount = Double(amount), amount > 0 else {
            errors.append("Please enter a valid amount")
            isErrorVisible = true
            return
        }
        
        guard !expenseName.isEmpty else {
            errors.append("Please enter an expense name")
            isErrorVisible = true
            return
        }
        
        guard !selectedParticipants.isEmpty else {
            errors.append("Please select at least one participant")
            isErrorVisible = true
            return
        }
        
        guard let outingId = outing.id?.uuidString else {
            errors.append("Invalid outing ID")
            isErrorVisible = true
            return
        }
        
        guard !paidById.isEmpty else {
            errors.append("Please select who paid for the expense")
            isErrorVisible = true
            return
        }
        
        outingCoreDataModel.addActivity(
            title: expenseName,
            description: "Expense added via mobile app",
            amount: amount,
            participantIds: Array(selectedParticipants),
            outingId: outingId,
            paidById: paidById
        )
        //dismiss()
    }
}





#Preview {
    let context = PersistenceController.preview.container.viewContext
    let outing = OutingEntity(context: context)
    outing.participants = """
        ["John Doe", "Jane Smith", "Mike Johnson"]
    """
    return AddExpenseDrawer(outing: outing)
}

