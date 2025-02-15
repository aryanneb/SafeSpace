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
    
    var body: some View {
        VStack {
            ScrollView {
                Text(outputText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            
            if viewModel.isProcessing {
                ProgressView()
                    .padding()
            }
            HStack {
                TextField("Ask me anything...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!viewModel.isModelLoaded)
                
                Button(action: askQuestion) {
                    Text("Ask")
                }
                .disabled(!viewModel.isModelLoaded || viewModel.isProcessing)
            }
            .padding()
        }
        .padding()
        .onAppear {
            viewModel.loadModel()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func askQuestion() {
        outputText = ""
        viewModel.ask(prompt: inputText) { response in
            outputText += response
        }
    }
}

class AIModelViewModel: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isProcessing = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var ai: AI?
    private let maxOutputLength = 512
    
    
    init() {
        // Initialize model parameters
        var params = ModelAndContextParams.default
        params.promptFormat = .Custom
        params.custom_prompt_format = """
        <|start_header_id|>system<|end_header_id|>
        You are a helpful AI assistant.<|eot_id|>
        <|start_header_id|>user<|end_header_id|>
        {prompt}<|eot_id|>
        <|start_header_id|>assistant<|end_header_id|>
        """
        params.use_metal = true
        
        // Get model path
        guard let modelPath = Bundle.main.path(forResource: "Llama-3.2-3B-Instruct-Q6_K_L", ofType: "gguf") else {
            showError(message: "Model file not found in bundle")
            return
        }
        
        // Initialize AI model
        ai = AI(_modelPath: modelPath, _chatName: "chat")
        ai?.initModel(ModelInference.LLama_gguf, contextParams: params)
        
        // Configure sampling parameters
        ai?.model?.sampleParams.mirostat = 2
        ai?.model?.sampleParams.mirostat_eta = 0.1
        ai?.model?.sampleParams.mirostat_tau = 5.0
    }
    
    func loadModel() {
        do {
            try ai?.loadModel_sync()
            isModelLoaded = true
        } catch {
            showError(message: "Failed to load model: \(error.localizedDescription)")
        }
    }
    
    func ask(prompt: String, responseHandler: @escaping (String) -> Void) {
        guard isModelLoaded else { return }
        
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            var totalOutput = 0
            let callback: (String, Double) -> Bool = { str, _ in
                DispatchQueue.main.async {
                    responseHandler(str)
                    totalOutput += str.count
                }
                return totalOutput > self.maxOutputLength
            }
            
            do {
                try self.ai?.model?.Predict(prompt, callback)
            } catch {
                self.showError(message: "Prediction failed: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
            self.isModelLoaded = false
            self.isProcessing = false
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
