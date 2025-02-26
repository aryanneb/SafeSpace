//
//  ChatButtonFunctions.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-25.
//

// MARK: - Chat View Model
import SwiftUI

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
        
        aiModel.resetModel()

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
