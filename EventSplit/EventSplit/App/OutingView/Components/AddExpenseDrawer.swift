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
    let onSuccess: () -> Void
    let outing: OutingDTO
    @Environment(\.dismiss) private var dismiss
    @State private var buttonState: ActionButtonState = .default
    private let outingService = OutingService(coreDataModel: OutingCoreDataModel())
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
    
    init(outing: OutingDTO, onSuccess: @escaping () -> Void) {
        self.outing = outing
        self.onSuccess = onSuccess
        
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
        
        allParticipants.append(contentsOf: outing.participants)
        
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
                HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add New Expense")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.secondaryBackground)
                    Text("Add and split expenses with your group")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.bottom, 8)
                
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
                        
                        // Warning Message
                        if selectedImage != nil {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Receipt analysis results may not be 100% accurate. Please verify all details before adding the expense.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Expense Details
                        VStack(alignment: .leading, spacing: 16) {
                            InputField(
                                text: $expenseName,
                                placeholder: "e.g., Dinner, Tickets, etc.",
                                icon: nil,
                                label: "Expense Name",
                                highlight: true
                            )
                            
                            if !expenseCategory.isEmpty {
                                HStack {
                                    Text(expenseCategory)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.secondaryBackground)
                                        .foregroundColor(.primaryBackground)
                                        .cornerRadius(16)
                                }
                            }
                            
                            InputField(
                                text: $amount,
                                placeholder: "$ 0.00",
                                icon: nil,
                                label: "Amount",
                                highlight: true
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
                        ActionButton(
                            title: "Add Expense",
                            action: addExpense,
                            state: buttonState,
                            fullWidth: true
                        )
                        
                        Text("Split expenses fairly and keep track of who owes what")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                    }
                }
                .padding(.horizontal, 2)
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
        buttonState = .loading
        
        guard let amount = Double(amount), amount > 0 else {
            errors.append("Please enter a valid amount")
            isErrorVisible = true
            buttonState = .error
            return
        }
        
        guard !expenseName.isEmpty else {
            errors.append("Please enter an expense name")
            isErrorVisible = true
            buttonState = .error
            return
        }
        
        guard !selectedParticipants.isEmpty else {
            errors.append("Please select at least one participant")
            isErrorVisible = true
            buttonState = .error
            return
        }
        
        guard !paidById.isEmpty else {
            errors.append("Please select who paid for the expense")
            isErrorVisible = true
            buttonState = .error
            return
        }
        
        outingService.addActivity(
            title: expenseName,
            description: "Expense added via mobile app",
            amount: amount,
            participantIds: Array(selectedParticipants),
            paidById: paidById,
            outingId: outing.id.uuidString,
            references: nil,
            completion: { result in
                switch result {
                case .success(let activityDTO):
                    if let image = selectedImage {
                        outingService.uploadActivityImage(
                            activityId: activityDTO.id.uuidString.lowercased(),
                            image: image
                        ) { uploadResult in
                            switch uploadResult {
                            case .success:
                                print("✅ Image uploaded successfully")
                                DispatchQueue.main.async {
                                    buttonState = .success
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        dismiss()
                                        onSuccess()
                                    }
                                }
                            case .failure(let error):
                                print("❌ Failed to upload image: \(error)")
                                DispatchQueue.main.async {
                                    errors.append("Failed to upload receipt image")
                                    isErrorVisible = true
                                    buttonState = .error
                                }
                            }
                        }
                    } else {
                        buttonState = .success
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                            onSuccess()
                        }
                    }
                case .failure(let error):
                    print("❌ Failed to add activity: \(error)")
                    DispatchQueue.main.async {
                        errors.append("Failed to add expense")
                        isErrorVisible = true
                    }
                }
            }
        )
    }
}


