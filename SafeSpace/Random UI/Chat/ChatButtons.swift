//
//  ChatButtons.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-17.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(Color(hex: "#1D2E0F"))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(hex: "#B3DA95"))
                .cornerRadius(10)
        }
    }
}

// MARK: - Chat View Model
public class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var showCopyConfirmation: Bool = false
    
    private let aiModel: AIModelViewModel
    
    init(aiModel: AIModelViewModel) {
        self.aiModel = aiModel
    }
    
    public func askQuestion() {
        guard !inputText.isEmpty else { return }
        
        // Clear all previous messages and reset context
        messages.removeAll()

        // Add the new user message
        let userMessage = Message(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let userInput = inputText
        inputText = ""
        
        // Send the user's prompt to the AI model
        aiModel.ask(prompt: userInput) { [weak self] response in
            guard let self = self else { return }
            // Check if last message is from user and if response is just whitespace/newlines
            if let lastMessage = self.messages.last, !lastMessage.isUser {
                self.messages[self.messages.count - 1] = Message(content: lastMessage.content + response, isUser: false)
            } else {
                let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedResponse.isEmpty { return }
                self.messages.append(Message(content: response, isUser: false))
            }
        }
    }
    
    public func continueGenerating() {
        var userInputEmptyFlag = true

        if !inputText.isEmpty {
            let userMessage = Message(content: inputText, isUser: true)
            messages.append(userMessage)
        }

        let userInput = inputText
        inputText = "" // Clear input field
        
        aiModel.ask(prompt: userInput) { [weak self] response in
            guard let self = self else { return }
            if let lastMessage = self.messages.last, !lastMessage.isUser {
                self.messages[self.messages.count - 1] = Message(content: lastMessage.content + response, isUser: false)
            } else {
                let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
                if userInputEmptyFlag && trimmedResponse.isEmpty { 
                    userInputEmptyFlag = false
                    return }
                self.messages.append(Message(content: response, isUser: false))
            }
        }
    }
    
    public func copyOutput() {
        let formattedMessages = messages
            .map { message in
                if message.isUser {
                    return "User: \(message.content)"
                } else {
                    return "AI Responded: \(message.content)"
                }
            }
            .joined(separator: "\n\n")
        
        UIPasteboard.general.string = formattedMessages
        showCopyConfirmation = true
    }
}

public struct ChatInputField: View {
    @ObservedObject var viewModel: ChatViewModel
    let isEnabled: Bool
    let characterLimit = 100
    
    public var body: some View {
        ZStack {
            TextField("Ask me anything...", text: Binding(
                get: { viewModel.inputText },
                set: { newValue in
                    viewModel.inputText = String(newValue.prefix(characterLimit))
                }
            ))
            .lineLimit(1)
            .truncationMode(.tail)
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.trailing, 60) 
            .foregroundColor(Color(hex: "#1D2E0F"))
            .background(Color(hex: "#FBF1DA"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#B3DA95"), lineWidth: 1)
            )
            .disabled(!isEnabled)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .tint(Color(hex: "#1D2E0F"))
            .onSubmit(viewModel.askQuestion)
            
            // Ask button positioned inside the text field
            HStack {
                Spacer()
                Button(action: viewModel.askQuestion) {
                    Text("Ask")
                        .foregroundColor(Color(hex: "#1D2E0F"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.inputText.isEmpty ?
                            Color(hex: "#FBF1DA") :
                            Color(hex: "#B3DA95")
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#B3DA95"), lineWidth: 1)
                        )
                }
                .disabled(!isEnabled)
                .padding(.trailing, 8)
            }
        }
        .padding(.horizontal)
    }
}

public struct ChatControlButtons: View {
    @ObservedObject var viewModel: ChatViewModel
    
    public var body: some View {
        HStack(spacing: 10) {
            ActionButton(title: "Generate More", action: viewModel.continueGenerating)
            ActionButton(title: "Copy Output", action: viewModel.copyOutput)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
} 
