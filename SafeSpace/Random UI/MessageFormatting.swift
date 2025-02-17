//
//  MessageFormatting.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-17.
//

import SwiftUI

// MARK: - Models
struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
    }
}

// MARK: - Views
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 2) {
            // Sender label with constrained height
            Text(message.isUser ? "User" : "AI")
                .font(.system(size: 8))
                .foregroundColor(Color(hex: "#1D2E0F"))
                .opacity(0.7)
                .frame(height: 10)
            
            // Content without spacer logic
            Text(message.content)
                .foregroundColor(Color(hex: "#1D2E0F"))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    message.isUser ? Color(hex: "#B3DA95") : Color(hex: "#FBF1DA")
                )
                .cornerRadius(16)
        }
        .padding(.horizontal, 8)
        .frame(
            maxWidth: .infinity,
            alignment: message.isUser ? .trailing : .leading
        )
    }
}
struct ChatMessageList: View {
    let messages: [Message]
    let onMessagesChange: () -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(messages) { message in
                    MessageBubble(message: message)
                }
            }
            .padding()
            .padding(.top, 2)
            .onChange(of: messages) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
} 
