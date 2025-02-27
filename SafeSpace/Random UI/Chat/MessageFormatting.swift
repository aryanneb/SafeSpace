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
    let index: Int
    @EnvironmentObject private var viewModel: ChatViewModel
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading) {
            Text(message.isUser ? "User" : "AI")
                .font(.system(size: 8))
                .foregroundColor(Color(hex: "#1D2E0F"))
                .opacity(0.7)
                .padding(.horizontal, message.isUser ? 14 : 14)
            
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
                    .modifier(AIMessageContextMenu(isUserMessage: message.isUser, index: index, viewModel: viewModel))
                
                if !message.isUser {
                    Spacer()
                }
            }
        }
    }
}

struct ChatMessage: View {
    let message: Message
    let index: Int
    @EnvironmentObject private var viewModel: ChatViewModel
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color(hex: "#B3DA95"))
                    .foregroundColor(Color(hex: "#1D2E0F"))
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color(hex: "#FFFFFF"))
                    .foregroundColor(Color(hex: "#1D2E0F"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .modifier(AIMessageContextMenu(isUserMessage: message.isUser, index: index, viewModel: viewModel))
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct ChatMessageList: View {
    let messages: [Message]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        MessageBubble(message: message, index: index)
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

struct AIMessageContextMenu: ViewModifier {
    let isUserMessage: Bool
    let index: Int
    let viewModel: ChatViewModel
    @ObservedObject private var aiModel: AIModelViewModel
    
    init(isUserMessage: Bool, index: Int, viewModel: ChatViewModel) {
        self.isUserMessage = isUserMessage
        self.index = index
        self.viewModel = viewModel
        self.aiModel = viewModel.aiModel
    }
    
    func body(content: Content) -> some View {
        if isUserMessage || aiModel.isProcessing {
            content
        } else {
            content.contextMenu {
                Button(action: {
                    viewModel.continueGenerating(forMessageAt: index)
                }) {
                    Label("Generate More", systemImage: "text.append")
                }
                
                Button(action: {
                    viewModel.regenerateResponse(forMessageAt: index)
                }) {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                }
                
                Button(action: {
                    viewModel.copyMessage(at: index)
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                
                Divider()
                
                Button(role: .destructive, action: {
                    viewModel.clearAllMessages()
                }) {
                    Label("Clear All Messages", systemImage: "trash")
                }
            }
        }
    }
} 
