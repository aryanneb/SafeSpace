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
    
    let aiModel: AIModelViewModel
    
    init(aiModel: AIModelViewModel) {
        self.aiModel = aiModel
    }
    
    public func clearAllMessages() {
        messages.removeAll()
        aiModel.resetModel()
    }
    
    // Helper function to get output from the AI model with consistent handling
    private func getOutput(
        prompt: String,
        updateMessage: @escaping (String) -> Void,
        appendToExisting: Bool = false,
        systemPrompt: String? = nil
    ) {
        aiModel.ask(prompt: prompt, responseHandler: { response in
            // Check if response is just whitespace/newlines when not appending
            if !appendToExisting {
                let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedResponse.isEmpty { return }
            }
            updateMessage(response)
        }, systemPrompt: systemPrompt)
    }
    
    // Update askQuestion to use the improved getOutput function
    public func askQuestion() {
        guard !inputText.isEmpty else { return }
        
        // Add the new user message
        let userMessage = Message(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let userInput = inputText
        inputText = ""
        
        // Send the user's prompt to the AI model
        getOutput(prompt: userInput, updateMessage: { [weak self] response in
            guard let self = self else { return }
            if let lastMessage = self.messages.last, !lastMessage.isUser {
                self.messages[self.messages.count - 1] = Message(content: lastMessage.content + response, isUser: false)
            } else {
                self.messages.append(Message(content: response, isUser: false))
            }
        })
    }
    
    // Generate more text for the selected AI message
    public func continueGenerating(forMessageAt index: Int) {
        guard index < messages.count, !messages[index].isUser else { return }
        
        // Find the last user message before this AI message
        var userPromptIndex = -1
        for i in (0..<index).reversed() {
            if messages[i].isUser {
                userPromptIndex = i
                break
            }
        }
        
        // If we can't find a user message, use empty string as fallback
        let userPrompt = userPromptIndex >= 0 ? messages[userPromptIndex].content : ""
        
        let messageIndex = index
        let currentContent = messages[messageIndex].content
        
        // Create a system prompt that instructs the AI to continue from the previous response
        let systemPrompt = """
        Previously, the user asked: "\(userPrompt)"
        
        You responded with: "\(currentContent)"
        
        Continue generating from where you left off, maintaining the same tone, style, and context.
        Make sure your continuation flows naturally from the previous text.
        """
        
        getOutput(
            prompt: userPrompt,  // Use the original user prompt instead of empty string
            updateMessage: { [weak self] response in
                guard let self = self else { return }
                if messageIndex < self.messages.count {
                    self.messages[messageIndex] = Message(content: self.messages[messageIndex].content + response, isUser: false)
                }
            },
            appendToExisting: true,  // We're always appending to existing content here
            systemPrompt: systemPrompt
        )
    }
    
    // Regenerate an AI response using the original user prompt
    public func regenerateResponse(forMessageAt index: Int) {
        guard index < messages.count, !messages[index].isUser else { return }
        
        // Find the last user message before this AI message
        var userPromptIndex = -1
        for i in (0..<index).reversed() {
            if messages[i].isUser {
                userPromptIndex = i
                break
            }
        }
        
        guard userPromptIndex >= 0 else { return }
        
        // Get the user prompt
        let userPrompt = messages[userPromptIndex].content
        
        // Remove all messages after the selected AI message
        if index + 1 < messages.count {
            messages.removeSubrange((index + 1)...messages.count - 1)
        }
        
        // Clear the selected message content and regenerate
        messages[index] = Message(content: "", isUser: false)
        
        getOutput(prompt: userPrompt, updateMessage: { [weak self] response in
            guard let self = self else { return }
            if index < self.messages.count {
                self.messages[index] = Message(content: self.messages[index].content + response, isUser: false)
            }
        })
    }
    
    // Copy the text of a specific AI message
    public func copyMessage(at index: Int) {
        guard index < messages.count else { return }
        
        let messageContent = messages[index].content
        UIPasteboard.general.string = messageContent
        showCopyConfirmation = true
    }
}