//
//  ButtonFunctions.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-17.
//

import SwiftUI


// MARK: - Chat Handling
public class ChatHandler: ObservableObject {
    @Published var messages: [Message] = []
    @Published public var inputText: String = ""
    @Published public var showCopyConfirmation: Bool = false
    
    private let aiModel: AIModelViewModel
    
    init(aiModel: AIModelViewModel) {
        self.aiModel = aiModel
    }
    
    public func askQuestion() {
        guard !inputText.isEmpty else { return }
        
        let userMessage = Message(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let userInput = inputText
        inputText = ""
        
        aiModel.ask(prompt: userInput) { [weak self] response in
            guard let self = self else { return }
            self.appendOrUpdateMessage(content: response)
        }
    }
    
    public func continueGenerating() {
        guard let lastMessage = messages.last, !lastMessage.isUser else { return }
        
        aiModel.ask(prompt: inputText) { [weak self] response in
            guard let self = self else { return }
            if let lastMessage = self.messages.last, !lastMessage.isUser {
                self.messages[self.messages.count - 1] = Message(
                    content: lastMessage.content + response,
                    isUser: false
                )
            } else {
                self.messages.append(Message(
                    content: response.trimmingCharacters(in: .whitespacesAndNewlines),
                    isUser: false
                ))
            }
        }
    }
    
    public func copyOutput() {
        let aiResponses = messages
            .filter { !$0.isUser }
            .map { $0.content }
            .joined(separator: "\n\n")
        
        UIPasteboard.general.string = aiResponses
        showCopyConfirmation = true
    }
}
