import SwiftUI
import llmfarm_core

struct ChatSpace: View {
    @StateObject private var aiModel = AIModelViewModel()
    @StateObject private var chatHandler: ChatHandler
    
    init() {
        let aiModelInstance = AIModelViewModel()
        
        _aiModel = StateObject(wrappedValue: aiModelInstance)
        _chatHandler = StateObject(wrappedValue: ChatHandler(aiModel: aiModelInstance))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ChatMessageList(messages: chatHandler.messages) {
                    // Handle messages change
                }
            }
            .background(Color(hex: "#FBF1DA"))
            
            if !chatHandler.messages.isEmpty && !aiModel.isProcessing {
                ChatControlButtons(viewModel: chatHandler)
            }
            
            if aiModel.isProcessing {
                ProgressView()
                    .padding()
                    .tint(Color(hex: "#1D2E0F"))
            }
            
            ChatInputField(
                viewModel: chatHandler,
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
        .alert("Copied to Clipboard!", isPresented: $chatHandler.showCopyConfirmation) {
            Button("Continue", role: .cancel) { }
        }
        .onChange(of: chatHandler.messages) { _ in
            if let aiMessage = chatHandler.messages.last(where: { !$0.isUser }) {
                print("DEBUG CONTENT: |\(aiMessage.content)|")
            }
        }
    }
}

#Preview {
    ChatSpace()
}
