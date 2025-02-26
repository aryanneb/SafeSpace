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
        VStack(alignment: message.isUser ? .trailing : .leading) {
            Text(message.isUser ? "User" : "AI")
                .font(.system(size: 8))
                .foregroundColor(Color(hex: "#1D2E0F"))
                .opacity(0.7)
                .padding(.horizontal, message.isUser ? 14 : 0)
            
            HStack {
                if message.isUser {
                    Spacer()
                }
                
                Text(message.content)
                    .foregroundColor(Color(hex: "#1D2E0F"))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        message.isUser ? Color(hex: "#B3DA95") : Color(hex: "#FBF1DA")
                    )
                    .cornerRadius(16)
                    .padding(.horizontal, 4)
                
                if !message.isUser {
                    Spacer()
                }
            }
        }
    }
}

struct ChatMessageList: View {
    let messages: [Message]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
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
} 
