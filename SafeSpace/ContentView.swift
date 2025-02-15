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
                    .foregroundColor(.white)
                    .background(Color(hex: "#002804"))
            }
            .background(Color(hex: "#002804"))
            
            // Control Buttons
            if !outputText.isEmpty && !viewModel.isProcessing {
                HStack(spacing: 20) {
                    Button(action: continueGenerating) {
                        Text("Continue Generating")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#005909"))
                            .cornerRadius(10)
                    }
                    
                    Button(action: copyOutput) {
                        Text("Copy Output")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#005909"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            if viewModel.isProcessing {
                ProgressView()
                    .padding()
            }
            
            HStack(alignment: .bottom) {
                TextField("Ask AI...", text: $inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color(hex: "#333333"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#005909"), lineWidth: 1)
                    )
                    .disabled(!viewModel.isModelLoaded)
                    .frame(minHeight: 40) 
                    .tint(.white)
                
                Button(action: askQuestion) {
                    Text("Ask")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "#005909"))
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isModelLoaded || viewModel.isProcessing)
            }
            .padding()
        }
        .padding()
        .background(Color(hex: "#002804"))
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
        viewModel.ask(prompt: inputText + outputText) { response in
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
