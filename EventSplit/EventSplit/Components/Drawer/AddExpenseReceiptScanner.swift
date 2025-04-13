//
//  AddExpenseReceiptScanner.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-08.
//
import SwiftUI
import UIKit
import PhotosUI

struct AddExpenseReceiptScanner: View {
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool
    @Binding var isCameraPresented: Bool
    var onAnalysis: (ReceiptAnalysis) -> Void
    @State private var extractedText: String = ""
    @State private var receiptAnalysis: ReceiptAnalysis?
    @State private var isProcessing: Bool = false
    private let llmService = LLMService()
    @State private var processedImageHash: Int = 0
    
    private func processImage(_ image: UIImage) {
        let newImageHash = image.hashValue
        guard !isProcessing && newImageHash != processedImageHash else { return }
        
        isProcessing = true
        processedImageHash = newImageHash
        
        TextExtractor.extractText(from: image) { result in
            if let text = result {
                extractedText = text
                
                llmService.analyzeReceipt(receiptText: text) { result in
                    DispatchQueue.main.async {
                        isProcessing = false
                        switch result {
                        case .success(let analysis):
                            self.receiptAnalysis = analysis
                            self.onAnalysis(analysis)
                        case .failure(let error):
                            print("❌ Analysis failed: \(error)")
                        }
                    }
                }
                
                /* self.llmService.analyzeReceiptUsingVision(image: image) { coreMLResult in
                    switch coreMLResult {
                    case .success(let analysis):
                        DispatchQueue.main.async {
                            self.isProcessing = false
                            self.receiptAnalysis = analysis
                            self.onAnalysis(analysis)
                        }
                    case .failure(let error):
                        print("❌ CoreML Analysis failed: \(error)")
                        // Fallback to API
                        self.llmService.analyzeReceipt(receiptText: text) { apiResult in
                            DispatchQueue.main.async {
                                self.isProcessing = false
                                switch apiResult {
                                case .success(let analysis):
                                    self.receiptAnalysis = analysis
                                    self.onAnalysis(analysis)
                                case .failure(let error):
                                    print("API Analysis failed: \(error)")
                                }
                            }
                        }
                    }
                }
                */
            } else {
                DispatchQueue.main.async {
                    isProcessing = false
                    print("❌ No text could be extracted from the image")
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Receipt Photo")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(height: 150)
                    .background(.primaryBackground)
                    .cornerRadius(12)
                
                if isProcessing {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Analyzing receipt...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                } else if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .onAppear {
                            processImage(image)
                        }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "dollarsign.square")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        
                        Text("Upload a receipt photo or take a picture")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 20) {
                            Button(action: { isCameraPresented = true }) {
                                HStack {
                                    Image(systemName: "camera")
                                        .foregroundColor(.secondaryBackground)
                                    Text("Camera")
                                        .foregroundColor(.secondaryBackground)
                                }
                            }
                            
                            Button(action: { isImagePickerPresented = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.secondaryBackground)
                                    Text("Upload")
                                        .foregroundColor(.secondaryBackground)
                                }
                            }
                        }
                    }
                    
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Why upload a receipt?")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                BulletPoint("We'll automatically extract the total amount")
                BulletPoint("Date and merchant details will be pre-filled")
                BulletPoint("Keep track of your expenses with proof")
            }
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                processImage(image)
            }
        }
    }
}

#Preview {
    AddExpenseReceiptScanner(
        selectedImage: .constant(nil),
        isImagePickerPresented: .constant(false),
        isCameraPresented: .constant(false),
        onAnalysis: { _ in }
    )
}
