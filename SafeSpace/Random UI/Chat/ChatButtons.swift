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
            .padding(.trailing, 56)
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
            
            // Arrow button positioned inside the text field
            HStack {
                Spacer()
                Button(action: viewModel.askQuestion) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: viewModel.inputText.isEmpty ? 28 : 32))
                        .foregroundColor(
                            viewModel.inputText.isEmpty ?
                            Color(hex: "#fbf1da") :
                            Color(hex: "#B3DA95")
                        )
                        .background(
                            Circle()
                                .fill(
                                    viewModel.inputText.isEmpty ? 
                                    Color(hex: "#B3DA95") :
                                    Color(hex: "#fbf1da")
                                )
                        )
                }
                .disabled(!isEnabled)
                .padding(.trailing, viewModel.inputText.isEmpty ? 16 : 14)
            }
        }
        .padding(.horizontal)
    }
}

// Note: ChatControlButtons has been removed as it's no longer needed 
