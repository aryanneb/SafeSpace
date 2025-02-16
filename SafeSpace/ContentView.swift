//
//  ContentView.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-08.
//

import SwiftUI
import llmfarm_core

struct ContentView: View {
    @StateObject private var viewModel = AIModelViewModel()
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var showCopyConfirmation = false
    
    var body: some View {
        VStack {
            ScrollView {
                Text(outputText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(Color(hex: "#1D2E0F"))
                    .background(Color(hex: "#FBF1DA"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#B3DA95"), lineWidth: 1)
                    )
            }
            .background(Color(hex: "#FBF1DA"))
            
            // Control Buttons
            if !outputText.isEmpty && !viewModel.isProcessing {
                HStack(spacing: 10) {
                    Button(action: continueGenerating) {
                        Text("Generate More")
                            .foregroundColor(Color(hex: "#1D2E0F"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#B3DA95"))
                            .cornerRadius(10)
                    }
                    
                    Button(action: copyOutput) {
                        Text("Copy Output")
                            .foregroundColor(Color(hex: "#1D2E0F"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#B3DA95"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 0)
            }
            
            if viewModel.isProcessing {
                ProgressView()
                    .padding()
                    .tint(Color(hex: "#1D2E0F"))
            }
            
            HStack(alignment: .center) {
                TextField("Ask me anything...", text: $inputText, axis: .vertical)
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
                    .disabled(!viewModel.isModelLoaded)
                    .frame(height: 36)
                    .tint(Color(hex: "#1D2E0F"))
                
                Button(action: askQuestion) {
                    Text("Ask")
                        .foregroundColor(Color(hex: "#1D2E0F"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#B3DA95"))
                        .cornerRadius(10)
                }
                .frame(height: 36)
                .disabled(!viewModel.isModelLoaded || viewModel.isProcessing)
            }
            .padding()
        }
        .padding()
        .background(Color(hex: "#FBF1DA"))
        .onAppear {
            viewModel.loadModel()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Copied!", isPresented: $showCopyConfirmation) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func askQuestion() {
        outputText = ""
        viewModel.ask(prompt: inputText) { response in
            outputText += response
        }
    }
    
    private func continueGenerating() {
        viewModel.ask(prompt: inputText) { response in
            outputText += response
        }
    }
    
    private func copyOutput() {
        UIPasteboard.general.string = outputText
        showCopyConfirmation = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
