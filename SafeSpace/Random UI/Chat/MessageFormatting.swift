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
    @State private var showTools: Bool = false
    
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
                
                VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
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
                    
                    // Tools button and expandable options for AI messages - simplified condition
                    if !message.isUser {
                        HStack {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showTools.toggle()
                                }
                            }) {
                                Image(systemName: showTools ? "xmark.circle.fill" : "ellipsis.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(showTools ? Color.red : Color(hex: "#B3DA95"))
                                    .padding(4)
                            }
                            .disabled(viewModel.aiModel.isProcessing)
                            
                            Spacer()
                        }
                        .padding(.leading, 10)
                        
                        if showTools {
                            HStack(spacing: 12) {
                                ToolButton(
                                    icon: "text.append",
                                    label: "Generate More",
                                    action: { viewModel.continueGenerating(forMessageAt: index) },
                                    isDisabled: viewModel.aiModel.isProcessing
                                )
                                
                                ToolButton(
                                    icon: "arrow.clockwise",
                                    label: "Regenerate",
                                    action: { viewModel.regenerateResponse(forMessageAt: index) },
                                    isDisabled: viewModel.aiModel.isProcessing
                                )
                                
                                ToolButton(
                                    icon: "doc.on.doc",
                                    label: "Copy",
                                    action: { viewModel.copyMessage(at: index) },
                                    isDisabled: false
                                )
                                
                                ToolButton(
                                    icon: "trash",
                                    label: "Clear All",
                                    action: { viewModel.clearAllMessages() },
                                    isDisabled: false,
                                    destructive: true
                                )
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#FBF1DA").opacity(0.9))
                            .cornerRadius(12)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                        }
                    }
                }
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

// New component for tool buttons
struct ToolButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    let isDisabled: Bool
    var destructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(destructive ? Color.red : Color(hex: "#1D2E0F"))
                
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(destructive ? Color.red : Color(hex: "#1D2E0F"))
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(Color(hex: "#B3DA95").opacity(0.7))
            .cornerRadius(8)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
    }
} 
