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

public struct ChatInputField: View {
    @ObservedObject var viewModel: ChatHandler
    let isEnabled: Bool
    
    public var body: some View {
        HStack(alignment: .center) {
            TextField("Ask me anything...", text: $viewModel.inputText, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .foregroundColor(Color(hex: "#1D2E0F"))
                .background(Color(hex: "#FBF1DA"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "#B3DA95"), lineWidth: 1)
                )
                .disabled(!isEnabled)
                .frame(height: 36)
                .tint(Color(hex: "#1D2E0F"))
                .onSubmit(viewModel.askQuestion)
            
            ActionButton(title: "Ask", action: viewModel.askQuestion)
                .frame(height: 36)
                .disabled(!isEnabled)
        }
    }
}

public struct ChatControlButtons: View {
    @ObservedObject var viewModel: ChatHandler
    
    public var body: some View {
        HStack(spacing: 10) {
            ActionButton(title: "Generate More", action: viewModel.continueGenerating)
            ActionButton(title: "Copy Output", action: viewModel.copyOutput)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
