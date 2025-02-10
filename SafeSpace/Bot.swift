//
//  Bot.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-10.
//

import Foundation
import LLM
import SwiftUI

// A Bot class that subclasses LLM. It defines the remote and local URLs.
// Its asynchronous initializer assumes that the model file is already downloaded.
class Bot: LLM {
    // The URL to download the model file from.
    static let remoteModelURL = URL(string: "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q6_K.gguf")!
    
    // Local file URL where the model will be stored (in the Documents directory).
    static func localModelFileURL() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("tinyllama-1.1b-chat-v1.0.Q6_K.gguf")
    }
    
    // A flag indicating whether the model file is already downloaded.
    static var isModelDownloaded: Bool {
        FileManager.default.fileExists(atPath: localModelFileURL().path)
    }
    
    // Define an error type to throw if the model is not present.
    enum BotError: Error {
        case modelNotDownloaded
    }
    
    // Initialize the Bot asynchronously, assuming the model file is present locally.
    convenience init() async throws {
        let fileURL = Bot.localModelFileURL()
        // Check if the model file is downloaded; if not, throw an error.
        guard Bot.isModelDownloaded else {
            throw BotError.modelNotDownloaded
        }
        let systemPrompt = "You are a sentient AI with emotions."
        self.init(from: fileURL, template: .chatML(systemPrompt))
    }
    
    // A helper function to send a message and update the output.
    func send(text: String) async {
        let processedInput = self.preprocess(text, self.history)
        let answer = await self.getCompletion(from: processedInput)
        await self.setOutput(to: answer)
    }
}
