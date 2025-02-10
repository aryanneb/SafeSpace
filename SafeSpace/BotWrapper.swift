//
//  BotWrapper.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-10.
//

import Foundation
import SwiftUI

class BotWrapper: ObservableObject {
    @Published var bot: Bot?
    @Published var output: String = ""
    @Published var isLoading: Bool = true
    
    init() {
        Task {
            await initializeBotIfPossible()
        }
    }
    
    // Attempt to initialize Bot if the model is downloaded.
    func initializeBotIfPossible() async {
        if Bot.isModelDownloaded {
            do {
                let botInstance = try await Bot()
                await MainActor.run {
                    self.bot = botInstance
                    self.isLoading = false
                }
            } catch {
                print("Error initializing Bot: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        } else {
            // Remain loading until the model file is present.
            await MainActor.run { self.isLoading = true }
        }
    }
    
    // Send a message via the Bot and update the output.
    func send(text: String) async {
        guard let bot = bot else { return }
        await bot.send(text: text)
        await MainActor.run {
            self.output = bot.output
        }
    }
}
