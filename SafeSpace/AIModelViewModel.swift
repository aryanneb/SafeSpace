//
//  AIModelViewModel.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-15.
//

import SwiftUI
import llmfarm_core

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
        <|begin_of_text|><|start_header_id|>You are SafeSpace, a caring AI companion. Be empathetic, supportive, and non-judgmental. 
        Listen carefully and provide thoughtful guidance while acknowledging your limitations.
        Prioritize emotional support and suggest professional help when needed.<|end_header_id|>

        Cutting Knowledge Date: December 2023
        Today Date: 26 Jul 2024

        {system_prompt}<|eot_id|><|start_header_id|>user<|end_header_id|>

        {prompt}<|eot_id|><|start_header_id|>assistant<|end_header_id|>
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
        print("Prompt: \(prompt)")
        print("Prompt length: \(prompt.count) characters")

        
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
