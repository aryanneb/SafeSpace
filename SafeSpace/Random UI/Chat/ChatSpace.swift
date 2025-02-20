//
//  ChatSpace.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-17.
//

import SwiftUI
import llmfarm_core

struct ChatSpace: View {
    @StateObject private var aiModel = AIModelViewModel()
    @StateObject private var chatViewModel: ChatViewModel
    
    init() {
        let aiModel = AIModelViewModel()
        _aiModel = StateObject(wrappedValue: aiModel)
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(aiModel: aiModel))
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ChatMessageList(messages: chatViewModel.messages)
                .background(Color(hex: "#FBF1DA"))
            
            if !chatViewModel.messages.isEmpty && !aiModel.isProcessing {
                ChatControlButtons(viewModel: chatViewModel)
            }
            
            if aiModel.isProcessing {
                ProgressView()
                    .padding()
                    .tint(Color(hex: "#1D2E0F"))
            }
            
            ChatInputField(
                viewModel: chatViewModel,
                isEnabled: aiModel.isModelLoaded && !aiModel.isProcessing
            )
            .padding()
        }
        .padding()
        .background(Color(hex: "#FBF1DA"))
        .onAppear {
            aiModel.loadModel()
        }
        .alert("Error", isPresented: $aiModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(aiModel.errorMessage)
        }
        .alert("Copied to Clipboard!", isPresented: $chatViewModel.showCopyConfirmation) {
            Button("Continue", role: .cancel) { }
        }
    }
}

#Preview {
    ChatSpace()
}
